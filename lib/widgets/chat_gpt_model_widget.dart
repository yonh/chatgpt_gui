import 'package:chatgpt_gui/services/chatgpt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openai_api/openai_api.dart' hide Text;

import '../utils.dart';

class GptModelWidget extends HookWidget {
  final Function(String model)? onModelChanged;
  final bool isModelConfirmed;
  const GptModelWidget({
    super.key,
    required this.active,
    required this.isModelConfirmed,
    this.onModelChanged,
  });

  final String? active;

  @override
  Widget build(BuildContext context) {
    final state = useState<String>(Models.gpt3_5Turbo);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.model + ": "),
        !isModelConfirmed
            ? DropdownButton<String>(
                items: [
                  Models.gpt3_5Turbo,
                  Models.gpt4,
                  ModelsExtra.gpt4oMini,
                  Models.gpt3_5Turbo_1106,
                  ModelsExtra.claude_3_haiku,
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                value: state.value,
                onChanged: (value) {
                  if (value == null) return;
                  state.value = value;
                  onModelChanged?.call(value);
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(active ?? ""),
              ),
      ],
    );
  }
}
