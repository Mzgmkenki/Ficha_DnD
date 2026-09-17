import 'package:dnd_ficha_app/features/character/domain/value_objects/alignment.dart';
import 'package:flutter/material.dart';

/// Seletor de alinhamento.
///
/// Dropdown porque é o componente que a criação e a edição já usam para toda
/// escolha única (raça, classe, antecedente). Uma grade 3x3 de cartões seria
/// mais bonita, mas nove cartões não caem bem numa tela estreita e sairiam do
/// padrão do resto do formulário.
///
/// A descrição do alinhamento escolhido aparece abaixo do campo em vez de dentro
/// da lista: dentro, cada item viraria duas linhas e a lista precisaria de
/// rolagem própria no celular.
class AlignmentField extends StatelessWidget {
  const AlignmentField({
    required this.value,
    required this.onChanged,
    this.border = false,
    super.key,
  });

  /// Nulo é "não definido", que é uma opção válida da lista — e não a mesma
  /// coisa que Neutro.
  final CharacterAlignment? value;

  final ValueChanged<CharacterAlignment?> onChanged;

  /// Desenha a borda do campo, como faz a tela de edição.
  final bool border;

  /// Valor do item "Não definido" no dropdown.
  ///
  /// `DropdownButtonFormField` usa `null` para "nada selecionado", então a
  /// ausência precisa de um valor próprio, senão o campo aparece vazio em vez de
  /// dizer "Não definido".
  static const String undefinedValue = '__undefined__';

  @override
  Widget build(BuildContext context) {
    final selected = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected?.id ?? undefinedValue,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Alinhamento',
            border: border ? const OutlineInputBorder() : null,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: undefinedValue,
              child: Text(CharacterAlignment.undefinedLabel),
            ),
            for (final alignment in CharacterAlignment.ordered)
              DropdownMenuItem<String>(
                value: alignment.id,
                child: Text(
                  alignment.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (raw) {
            onChanged(
              raw == null || raw == undefinedValue
                  ? null
                  : CharacterAlignment.fromId(raw),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            selected?.description ??
                'Opcional. Pode ser escolhido depois, na ficha.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
