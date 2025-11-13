import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

final _generatedFilePatterns = [
  RegExp(r'\.g\.dart$'),
  RegExp(r'\.freezed\.dart$'),
  RegExp(r'\.pb\.dart$'),
  RegExp(r'\.mocks\.dart$'),
];

void main(List<String> args) async {
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    print('❌ No lib/ directory found. Run this from the project root.');
    exit(1);
  }

  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (_isGenerated(entity.path)) {
      print('Skipping generated file: ${entity.path}');
      continue;
    }

    final source = await entity.readAsString();
    final parseResult = parseString(content: source, path: entity.path);
    final unit = parseResult.unit;

    final edits = <_Edit>[];

    // ---------- Top-level Declarations ----------
    for (final decl in unit.declarations) {
      String? name;
      String kind = 'declaration';

      if (decl is ClassDeclaration) {
        name = decl.name.lexeme;
        kind = 'class $name';
      } else if (decl is EnumDeclaration) {
        name = decl.name.lexeme;
        kind = 'enum $name';
      } else if (decl is FunctionDeclaration) {
        name = decl.name.lexeme;
        kind = 'function $name';
      } else if (decl is TypeAlias) {
        name = decl.name.lexeme;
        kind = 'type alias $name';
      } else if (decl is TopLevelVariableDeclaration) {
        final vars = decl.variables.variables;
        if (vars.isNotEmpty) {
          name = vars.first.name.lexeme;
          kind = 'top-level variable $name';
        }
      }

      if (name != null && _isPublic(name) && _needsDoc(decl)) {
        final offset = _findLineStart(source, decl.offset);
        edits.add(_Edit(offset, '/// TODO: Document $kind.\n'));
      }
    }

    // ---------- Class Members ----------
    for (final classDecl in unit.declarations.whereType<ClassDeclaration>()) {
      if (!_isPublic(classDecl.name.lexeme)) continue;

      for (final member in classDecl.members) {
        if (!_needsDoc(member)) continue;

        if (member is MethodDeclaration && _isPublic(member.name.lexeme)) {
          final comment = _buildMethodDoc(member);
          edits.add(_Edit(_findLineStart(source, member.offset), comment));
        } else if (member is ConstructorDeclaration) {
          final ctorName = member.name?.lexeme ?? classDecl.name.lexeme;
          if (_isPublic(ctorName)) {
            final comment = _buildConstructorDoc(member, ctorName);
            edits.add(_Edit(_findLineStart(source, member.offset), comment));
          }
        } else if (member is FieldDeclaration) {
          final first = member.fields.variables.firstOrNull;
          if (first != null && _isPublic(first.name.lexeme)) {
            edits.add(
              _Edit(
                _findLineStart(source, member.offset),
                '/// TODO: Document field [${first.name.lexeme}].\n',
              ),
            );
          }
        }
      }
    }

    // ---------- Apply Edits ----------
    if (edits.isNotEmpty) {
      final backup = '${entity.path}.bak';
      await File(backup).writeAsString(source);
      print('📦 Backup created: $backup');

      var newCode = source;
      for (final edit in edits.reversed) {
        newCode = newCode.replaceRange(edit.offset, edit.offset, edit.text);
      }
      await entity.writeAsString(newCode);
      print('✏️  Updated ${entity.path} with ${edits.length} placeholder(s).');
    }
  }

  print('✅ Documentation scaffolding complete.');
}

// ---------- Helpers ----------

bool _isGenerated(String path) =>
    _generatedFilePatterns.any((r) => r.hasMatch(path));

bool _isPublic(String name) => !name.startsWith('_');

bool _needsDoc(Declaration decl) => decl.documentationComment == null;

int _findLineStart(String source, int offset) {
  var pos = offset;
  while (pos > 0 && source.codeUnitAt(pos - 1) != 10) pos--;
  return pos;
}

String _buildMethodDoc(MethodDeclaration method) {
  final buffer = StringBuffer();
  final name = method.name.lexeme;

  buffer.writeln('/// TODO: Document method [$name].');
  for (final param in method.parameters?.parameters ?? <FormalParameter>[]) {
    final paramName = _getParamName(param);
    if (paramName != null && _isPublic(paramName)) {
      buffer.writeln('/// @param $paramName TODO: describe this parameter.');
    }
  }

  final returnType = method.returnType?.toSource();
  if (returnType != null &&
      returnType != 'void' &&
      returnType != 'Future<void>') {
    buffer.writeln('/// @return TODO: describe return value.');
  }

  buffer.writeln();
  return buffer.toString();
}

String _buildConstructorDoc(ConstructorDeclaration ctor, String name) {
  final buffer = StringBuffer();
  buffer.writeln('/// TODO: Document constructor [$name].');
  for (final param in ctor.parameters.parameters) {
    final paramName = _getParamName(param);
    if (paramName != null && _isPublic(paramName)) {
      buffer.writeln('/// @param $paramName TODO: describe this parameter.');
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String? _getParamName(FormalParameter param) {
  if (param is SimpleFormalParameter) {
    // Dart 3.4+ uses .name instead of .identifier
    return param.name?.lexeme;
  } else if (param is DefaultFormalParameter) {
    // Unwrap inner parameter recursively
    return _getParamName(param.parameter);
  } else if (param is FieldFormalParameter) {
    // Handles "this.field" style parameters in constructors
    return param.name.lexeme;
  } else if (param is FunctionTypedFormalParameter) {
    // e.g. void Function(String)
    return param.name.lexeme;
  }
  return null;
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class _Edit {
  final int offset;
  final String text;

  _Edit(this.offset, this.text);
}
