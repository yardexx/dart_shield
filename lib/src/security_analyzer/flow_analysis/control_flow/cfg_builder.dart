import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/cfg_node_type.dart';
import 'package:dart_shield/src/security_analyzer/flow_analysis/control_flow/control_flow_graph.dart';

/// Builder for creating Control Flow Graphs from Dart AST
class CFGBuilder extends RecursiveAstVisitor<void> {
  late CFGNode _currentNode;
  late CFGNode _exitNode;
  final List<CFGNode> _breakTargets = [];
  final List<CFGNode> _continueTargets = [];
  int _nodeCounter = 0;

  /// Build CFG for a function or method
  ControlFlowGraph buildForFunction(FunctionDeclaration function) {
    return _buildForExecutable(function.functionExpression.body);
  }

  /// Build CFG for a method
  ControlFlowGraph buildForMethod(MethodDeclaration method) {
    return _buildForExecutable(method.body);
  }

  /// Build CFG for a constructor
  ControlFlowGraph buildForConstructor(ConstructorDeclaration constructor) {
    return _buildForExecutable(constructor.body);
  }

  ControlFlowGraph _buildForExecutable(FunctionBody? body) {
    _nodeCounter = 0;

    final entry = _createNode(CFGNodeType.entry, 'ENTRY');
    _exitNode = _createNode(CFGNodeType.exit, 'EXIT');
    final cfg = ControlFlowGraph(entry: entry, exit: _exitNode);

    _currentNode = entry;

    if (body != null) {
      body.accept(this);
    }

    // Connect current node to exit if not already connected
    if (_currentNode != _exitNode &&
        !_currentNode.successors.contains(_exitNode)) {
      _currentNode.addSuccessor(_exitNode);
    }

    // Add all created nodes to the CFG
    _addAllNodesToGraph(cfg, entry);

    return cfg;
  }

  void _addAllNodesToGraph(ControlFlowGraph cfg, CFGNode start) {
    final visited = <CFGNode>{};
    final queue = <CFGNode>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;

      visited.add(current);
      cfg.addNode(current);
      queue.addAll(current.successors);
    }
  }

  CFGNode _createNode(CFGNodeType type, String label, [AstNode? astNode]) {
    return CFGNode(
      id: 'node_${_nodeCounter++}',
      type: type,
      label: label,
      astNode: astNode,
    );
  }

  CFGNode _createStatementNode(Statement stmt) {
    final label = stmt.toString().replaceAll('\n', ' ').trim();
    final truncated = label.length > 50
        ? '${label.substring(0, 47)}...'
        : label;
    return _createNode(CFGNodeType.statement, truncated, stmt);
  }

  @override
  void visitBlock(Block node) {
    for (final statement in node.statements) {
      statement.accept(this);
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final stmtNode = _createStatementNode(node);
    _currentNode.addSuccessor(stmtNode);
    _currentNode = stmtNode;
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final stmtNode = _createStatementNode(node);
    _currentNode.addSuccessor(stmtNode);
    _currentNode = stmtNode;
  }

  @override
  void visitIfStatement(IfStatement node) {
    // Create condition node
    final conditionNode = _createNode(
      CFGNodeType.condition,
      'if (${node.expression})',
      node,
    );
    _currentNode.addSuccessor(conditionNode);

    // Create nodes for then and else branches
    final thenStart = _createNode(CFGNodeType.branch, 'then');
    final elseStart = _createNode(CFGNodeType.branch, 'else');

    conditionNode
      ..addSuccessor(thenStart)
      ..addSuccessor(elseStart);

    // Process then branch
    _currentNode = thenStart;
    node.thenStatement.accept(this);
    final thenEnd = _currentNode;

    // Process else branch
    _currentNode = elseStart;
    if (node.elseStatement != null) {
      node.elseStatement!.accept(this);
    }
    final elseEnd = _currentNode;

    // Create join node
    final joinNode = _createNode(CFGNodeType.statement, 'join');
    thenEnd.addSuccessor(joinNode);
    elseEnd.addSuccessor(joinNode);
    _currentNode = joinNode;
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    final loopHeader = _createNode(
      CFGNodeType.condition,
      'while (${node.condition})',
      node,
    );
    _currentNode.addSuccessor(loopHeader);

    final loopBody = _createNode(CFGNodeType.branch, 'loop body');
    final loopExit = _createNode(CFGNodeType.statement, 'loop exit');

    loopHeader
      ..addSuccessor(loopBody)
      ..addSuccessor(loopExit);

    // Set up break/continue targets
    _breakTargets.add(loopExit);
    _continueTargets.add(loopHeader);

    // Process loop body
    _currentNode = loopBody;
    node.body.accept(this);
    _currentNode.addSuccessor(loopHeader); // Back edge

    // Clean up targets
    _breakTargets.removeLast();
    _continueTargets.removeLast();

    _currentNode = loopExit;
  }

  @override
  void visitForStatement(ForStatement node) {
    // Handle initialization - could be variable declaration or expression
    if (node.forLoopParts is ForPartsWithDeclarations) {
      final forParts = node.forLoopParts as ForPartsWithDeclarations;
      // Process variable declarations
      if (forParts.variables.variables.isNotEmpty) {
        final initNode = _createNode(
          CFGNodeType.statement,
          'for init: ${forParts.variables}',
          forParts.variables,
        );
        _currentNode.addSuccessor(initNode);
        _currentNode = initNode;
      }
    } else if (node.forLoopParts is ForPartsWithExpression) {
      final forParts = node.forLoopParts as ForPartsWithExpression;
      // Process initialization expression
      if (forParts.initialization != null) {
        final initNode = _createNode(
          CFGNodeType.statement,
          'for init: ${forParts.initialization}',
          forParts.initialization,
        );
        _currentNode.addSuccessor(initNode);
        _currentNode = initNode;
      }
    }

    // Get condition and updaters based on the for loop parts type
    Expression? condition;
    var updaters = <Expression>[];

    if (node.forLoopParts is ForPartsWithDeclarations) {
      final forParts = node.forLoopParts as ForPartsWithDeclarations;
      condition = forParts.condition;
      updaters = forParts.updaters;
    } else if (node.forLoopParts is ForPartsWithExpression) {
      final forParts = node.forLoopParts as ForPartsWithExpression;
      condition = forParts.condition;
      updaters = forParts.updaters;
    }

    final loopHeader = _createNode(
      CFGNodeType.condition,
      'for (${condition?.toString() ?? 'true'})',
      node,
    );
    _currentNode.addSuccessor(loopHeader);

    final loopBody = _createNode(CFGNodeType.branch, 'for body');
    final loopExit = _createNode(CFGNodeType.statement, 'for exit');

    loopHeader
      ..addSuccessor(loopBody)
      ..addSuccessor(loopExit);

    // Set up break/continue targets
    final updateNode = _createNode(CFGNodeType.statement, 'for update');
    _breakTargets.add(loopExit);
    _continueTargets.add(updateNode);

    // Process loop body
    _currentNode = loopBody;
    node.body.accept(this);
    _currentNode.addSuccessor(updateNode);

    // Process update expressions
    _currentNode = updateNode;
    for (final updater in updaters) {
      final updateStmt = _createNode(
        CFGNodeType.statement,
        updater.toString(),
        updater,
      );
      _currentNode.addSuccessor(updateStmt);
      _currentNode = updateStmt;
    }
    _currentNode.addSuccessor(loopHeader); // Back edge

    // Clean up targets
    _breakTargets.removeLast();
    _continueTargets.removeLast();

    _currentNode = loopExit;
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    final returnNode = _createNode(
      CFGNodeType.return_,
      'return ${node.expression ?? ''}',
      node,
    );
    _currentNode.addSuccessor(returnNode);
    returnNode.addSuccessor(_exitNode);

    // Create unreachable node for statements after return
    _currentNode = _createNode(CFGNodeType.statement, 'unreachable');
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    final breakNode = _createStatementNode(node);
    _currentNode.addSuccessor(breakNode);

    if (_breakTargets.isNotEmpty) {
      breakNode.addSuccessor(_breakTargets.last);
    }

    // Create unreachable node
    _currentNode = _createNode(CFGNodeType.statement, 'unreachable');
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    final continueNode = _createStatementNode(node);
    _currentNode.addSuccessor(continueNode);

    if (_continueTargets.isNotEmpty) {
      continueNode.addSuccessor(_continueTargets.last);
    }

    // Create unreachable node
    _currentNode = _createNode(CFGNodeType.statement, 'unreachable');
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    final throwNode = _createNode(
      CFGNodeType.throw_,
      'throw ${node.expression}',
      node,
    );
    _currentNode.addSuccessor(throwNode);
    throwNode.addSuccessor(_exitNode);

    // Create unreachable node
    _currentNode = _createNode(CFGNodeType.statement, 'unreachable');
  }

  @override
  void visitTryStatement(TryStatement node) {
    final tryStart = _createNode(CFGNodeType.statement, 'try');
    _currentNode.addSuccessor(tryStart);

    // Process try block
    _currentNode = tryStart;
    node.body.accept(this);
    final tryEnd = _currentNode;

    final finallyStart = _createNode(CFGNodeType.statement, 'finally');

    // Process catch clauses
    for (final catchClause in node.catchClauses) {
      final catchStart = _createNode(
        CFGNodeType.catch_,
        'catch (${catchClause.exceptionParameter?.name ?? ''})',
        catchClause,
      );

      _currentNode = catchStart;
      catchClause.body.accept(this);
      _currentNode.addSuccessor(finallyStart);
    }

    // Connect try block to finally
    tryEnd.addSuccessor(finallyStart);

    // Process finally block
    if (node.finallyBlock != null) {
      _currentNode = finallyStart;
      node.finallyBlock!.accept(this);
    } else {
      _currentNode = finallyStart;
    }
  }
}
