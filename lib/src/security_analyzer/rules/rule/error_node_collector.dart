import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/visitor.dart';

abstract class ErrorNodeCollector extends RecursiveAstVisitor<void> {
  List<SyntacticEntity> errorNodes = [];
}
