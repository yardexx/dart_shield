import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';

class CFGBuilder extends RecursiveAstVisitor<void> {
  CFGBuilder();

  int _nextNodeId = 0;
  late CFGNode _currentNode;
  late CFGNode _entryNode;
  late CFGNode _exitNode;
  final List<CFGNode> _nodes = [];

  // Control flow state
  final List<CFGNode> _breakTargets = [];
  final List<CFGNode> _continueTargets = [];
  final List<CFGNode> _returnTargets = [];

  /// Build CFG for a function declaration
  ControlFlowGraph buildForFunction(FunctionDeclaration function) {
    _reset();
    _entryNode = _createNode(
      CFGNodeType.entry,
      label: 'Entry: ${function.name.lexeme}',
    );
    _exitNode = _createNode(
      CFGNodeType.exit,
      label: 'Exit: ${function.name.lexeme}',
    );
    _currentNode = _entryNode;
    _returnTargets.add(_exitNode);

    final body = function.functionExpression.body;
    _visitFunctionBody(body);

    // Connect current node to exit if not already connected
    if (_currentNode.successors.isEmpty && _currentNode != _exitNode) {
      _currentNode.addSuccessor(_exitNode);
    }

    return ControlFlowGraph(
      entryNode: _entryNode,
      exitNode: _exitNode,
      nodes: List.from(_nodes),
      functionNode: function,
    );
  }

  /// Build CFG for a method declaration
  ControlFlowGraph buildForMethod(MethodDeclaration method) {
    _reset();
    _entryNode = _createNode(
      CFGNodeType.entry,
      label: 'Entry: ${method.name.lexeme}',
    );
    _exitNode = _createNode(
      CFGNodeType.exit,
      label: 'Exit: ${method.name.lexeme}',
    );
    _currentNode = _entryNode;
    _returnTargets.add(_exitNode);

    final body = method.body;
    _visitFunctionBody(body);

    // Connect current node to exit if not already connected
    if (_currentNode.successors.isEmpty && _currentNode != _exitNode) {
      _currentNode.addSuccessor(_exitNode);
    }

    return ControlFlowGraph(
      entryNode: _entryNode,
      exitNode: _exitNode,
      nodes: List.from(_nodes),
      functionNode: method,
    );
  }

  /// Handle different types of function bodies
  void _visitFunctionBody(FunctionBody body) {
    if (body is BlockFunctionBody) {
      _visitStatement(body.block);
    } else if (body is ExpressionFunctionBody) {
      // Arrow function: => expression
      final node = _createNode(
        CFGNodeType.statement,
        expression: body.expression,
        label: 'return ${body.expression}',
      );
      _currentNode.addSuccessor(node);
      _currentNode = node;
    } else if (body is EmptyFunctionBody) {
      // Abstract or external function - no body to process
      return;
    }
  }

  void _reset() {
    _nextNodeId = 0;
    _nodes.clear();
    _breakTargets.clear();
    _continueTargets.clear();
    _returnTargets.clear();
  }

  CFGNode _createNode(
    CFGNodeType type, {
    Statement? statement,
    Expression? expression,
    String? label,
  }) {
    final node = CFGNode(
      id: _nextNodeId++,
      type: type,
      statement: statement,
      expression: expression,
      label: label,
    );
    _nodes.add(node);
    return node;
  }

  void _visitStatement(Statement statement) {
    if (statement is Block) {
      _visitBlockStatement(statement);
    } else if (statement is IfStatement) {
      _visitIfStatement(statement);
    } else if (statement is WhileStatement) {
      _visitWhileStatement(statement);
    } else if (statement is ForStatement) {
      _visitForStatement(statement);
    } else if (statement is ReturnStatement) {
      _visitReturnStatement(statement);
    } else if (statement is BreakStatement) {
      _visitBreakStatement(statement);
    } else if (statement is ContinueStatement) {
      _visitContinueStatement(statement);
    } else if (statement is TryStatement) {
      _visitTryStatement(statement);
    } else if (statement is ThrowExpression || statement is RethrowExpression) {
      _visitThrowStatement(statement);
    } else {
      // Regular statement
      final node = _createNode(CFGNodeType.statement, statement: statement);
      _currentNode.addSuccessor(node);
      _currentNode = node;

      // Extract variable definitions and uses
      _extractVariableInfo(node, statement);
    }
  }

  void _visitBlockStatement(Block block) {
    for (final statement in block.statements) {
      _visitStatement(statement);
    }
  }

  void _visitIfStatement(IfStatement ifStatement) {
    // Create condition node
    final conditionNode = _createNode(
      CFGNodeType.condition,
      expression: ifStatement.expression,
      label: 'if (${ifStatement.expression})',
    );
    _currentNode.addSuccessor(conditionNode);

    // Create merge node for after the if statement
    final mergeNode = _createNode(CFGNodeType.merge, label: 'if-merge');

    // Visit then branch
    _currentNode = conditionNode;
    _visitStatement(ifStatement.thenStatement);
    _currentNode.addSuccessor(mergeNode);

    // Visit else branch if it exists
    final elseStatement = ifStatement.elseStatement;
    if (elseStatement != null) {
      _currentNode = conditionNode;
      _visitStatement(elseStatement);
      _currentNode.addSuccessor(mergeNode);
    } else {
      // Direct path from condition to merge for false case
      conditionNode.addSuccessor(mergeNode);
    }

    _currentNode = mergeNode;
  }

  void _visitWhileStatement(WhileStatement whileStatement) {
    // Create condition node
    final conditionNode = _createNode(
      CFGNodeType.condition,
      expression: whileStatement.condition,
      label: 'while (${whileStatement.condition})',
    );
    _currentNode.addSuccessor(conditionNode);

    // Create merge node for after the loop
    final mergeNode = _createNode(CFGNodeType.merge, label: 'while-merge');

    // Set up break/continue targets
    _breakTargets.add(mergeNode);
    _continueTargets.add(conditionNode);

    // Visit body
    _currentNode = conditionNode;
    _visitStatement(whileStatement.body);

    // Loop back to condition
    _currentNode.addSuccessor(conditionNode);

    // Exit condition goes to merge
    conditionNode.addSuccessor(mergeNode);

    // Clean up break/continue targets
    _breakTargets.removeLast();
    _continueTargets.removeLast();

    _currentNode = mergeNode;
  }

  void _visitForStatement(ForStatement forStatement) {
    // Handle initialization
    final forLoopParts = forStatement.forLoopParts;

    if (forLoopParts is ForPartsWithDeclarations) {
      // for (var i = 0; ...)
      final variables = forLoopParts.variables;
      final initNode = _createNode(
        CFGNodeType.statement,
        label: 'for-init: ${variables.toString()}',
      );
      _currentNode.addSuccessor(initNode);
      _currentNode = initNode;

      // Extract variable info for data flow analysis
      final extractor = _VariableExtractor();
      variables.accept(extractor);
      initNode.definitions.addAll(extractor.definitions);
      initNode.uses.addAll(extractor.uses);

      // Create condition node
      final conditionNode = _createNode(
        CFGNodeType.condition,
        expression: forLoopParts.condition,
        label: 'for-condition',
      );
      _currentNode.addSuccessor(conditionNode);

      // Create merge node for after the loop
      final mergeNode = _createNode(CFGNodeType.merge, label: 'for-merge');

      // Create update node
      final updateNode = _createNode(
        CFGNodeType.statement,
        label: 'for-update',
      );

      // Set up break/continue targets
      _breakTargets.add(mergeNode);
      _continueTargets.add(updateNode);

      // Visit body
      _currentNode = conditionNode;
      _visitStatement(forStatement.body);

      // Connect body to update
      _currentNode.addSuccessor(updateNode);

      // Handle updaters
      for (final updater in forLoopParts.updaters) {
        final updaterNode = _createNode(
          CFGNodeType.statement,
          expression: updater,
          label: 'update: $updater',
        );
        updateNode.addSuccessor(updaterNode);
      }

      // Update loops back to condition
      updateNode.addSuccessor(conditionNode);

      // Exit condition goes to merge
      conditionNode.addSuccessor(mergeNode);

      // Clean up break/continue targets
      _breakTargets.removeLast();
      _continueTargets.removeLast();

      _currentNode = mergeNode;
    } else if (forLoopParts is ForPartsWithExpression) {
      // for (i = 0; ...)
      if (forLoopParts.initialization != null) {
        final initNode = _createNode(
          CFGNodeType.statement,
          expression: forLoopParts.initialization!,
          label: 'for-init',
        );
        _currentNode.addSuccessor(initNode);
        _currentNode = initNode;
      }

      // Similar logic for condition, body, and updaters...
      final conditionNode = _createNode(
        CFGNodeType.condition,
        expression: forLoopParts.condition,
        label: 'for-condition',
      );
      _currentNode.addSuccessor(conditionNode);

      final mergeNode = _createNode(CFGNodeType.merge, label: 'for-merge');
      final updateNode = _createNode(
        CFGNodeType.statement,
        label: 'for-update',
      );

      _breakTargets.add(mergeNode);
      _continueTargets.add(updateNode);

      _currentNode = conditionNode;
      _visitStatement(forStatement.body);
      _currentNode.addSuccessor(updateNode);

      updateNode.addSuccessor(conditionNode);
      conditionNode.addSuccessor(mergeNode);

      _breakTargets.removeLast();
      _continueTargets.removeLast();

      _currentNode = mergeNode;
    } else if (forLoopParts is ForEachPartsWithDeclaration) {
      // for (var item in items)
      final iterableNode = _createNode(
        CFGNodeType.statement,
        expression: forLoopParts.iterable,
        label: 'for-each setup',
      );
      _currentNode.addSuccessor(iterableNode);

      final conditionNode = _createNode(
        CFGNodeType.condition,
        label: 'for-each condition',
      );
      iterableNode.addSuccessor(conditionNode);

      final mergeNode = _createNode(CFGNodeType.merge, label: 'for-each-merge');

      _breakTargets.add(mergeNode);
      _continueTargets.add(conditionNode);

      _currentNode = conditionNode;
      _visitStatement(forStatement.body);
      _currentNode.addSuccessor(conditionNode);

      conditionNode.addSuccessor(mergeNode);

      _breakTargets.removeLast();
      _continueTargets.removeLast();

      _currentNode = mergeNode;
    }
  }

  void _visitReturnStatement(Statement statement) {
    final node = _createNode(CFGNodeType.return_, statement: statement);
    _currentNode.addSuccessor(node);

    // Return goes to exit
    if (_returnTargets.isNotEmpty) {
      node.addSuccessor(_returnTargets.last);
    }

    // No further statements reachable
    _currentNode = _createNode(CFGNodeType.statement, label: 'unreachable');
  }

  void _visitBreakStatement(Statement statement) {
    final node = _createNode(CFGNodeType.break_, statement: statement);
    _currentNode.addSuccessor(node);

    // Break goes to break target
    if (_breakTargets.isNotEmpty) {
      node.addSuccessor(_breakTargets.last);
    }

    // No further statements reachable
    _currentNode = _createNode(CFGNodeType.statement, label: 'unreachable');
  }

  void _visitContinueStatement(Statement statement) {
    final node = _createNode(CFGNodeType.continue_, statement: statement);
    _currentNode.addSuccessor(node);

    // Continue goes to continue target
    if (_continueTargets.isNotEmpty) {
      node.addSuccessor(_continueTargets.last);
    }

    // No further statements reachable
    _currentNode = _createNode(CFGNodeType.statement, label: 'unreachable');
  }

  void _visitTryStatement(TryStatement tryStatement) {
    // Simplified try-catch handling
    // Create try block
    final tryNode = _createNode(CFGNodeType.statement, label: 'try-block');
    _currentNode.addSuccessor(tryNode);

    final mergeNode = _createNode(CFGNodeType.merge, label: 'try-merge');

    // Visit try body
    _currentNode = tryNode;
    _visitStatement(tryStatement.body);
    _currentNode.addSuccessor(mergeNode);

    // Visit catch clauses
    for (final catchClause in tryStatement.catchClauses) {
      final catchNode = _createNode(
        CFGNodeType.statement,
        label: 'catch-block',
      );
      tryNode.addSuccessor(catchNode); // Exception can occur anywhere in try

      _currentNode = catchNode;
      _visitStatement(catchClause.body);
      _currentNode.addSuccessor(mergeNode);
    }

    // Visit finally block
    final finallyBlock = tryStatement.finallyBlock;
    if (finallyBlock != null) {
      final finallyNode = _createNode(
        CFGNodeType.statement,
        label: 'finally-block',
      );
      mergeNode.addSuccessor(finallyNode);

      _currentNode = finallyNode;
      _visitStatement(finallyBlock);

      final finalMergeNode = _createNode(
        CFGNodeType.merge,
        label: 'finally-merge',
      );
      _currentNode.addSuccessor(finalMergeNode);
      _currentNode = finalMergeNode;
    } else {
      _currentNode = mergeNode;
    }
  }

  void _visitThrowStatement(Statement statement) {
    final node = _createNode(CFGNodeType.throw_, statement: statement);
    _currentNode.addSuccessor(node);

    // Throw terminates normal execution
    _currentNode = _createNode(CFGNodeType.statement, label: 'unreachable');
  }

  void _extractVariableInfo(CFGNode node, Statement statement) {
    final extractor = _VariableExtractor();
    statement.accept(extractor);

    node.definitions.addAll(extractor.definitions);
    node.uses.addAll(extractor.uses);
  }
}

/// Extracts variable definitions and uses from AST nodes
class _VariableExtractor extends RecursiveAstVisitor<void> {
  final Set<String> definitions = <String>{};
  final Set<String> uses = <String>{};

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    for (final variable in node.variables.variables) {
      if (variable.name.lexeme.isNotEmpty) {
        definitions.add(variable.name.lexeme);
      }
      // Visit initializer for uses
      variable.initializer?.accept(this);
    }
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    // Left side is a definition
    if (node.leftHandSide is SimpleIdentifier) {
      final identifier = node.leftHandSide as SimpleIdentifier;
      definitions.add(identifier.name);
    }

    // Right side contains uses
    node.rightHandSide.accept(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // This is a use of a variable
    uses.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}
