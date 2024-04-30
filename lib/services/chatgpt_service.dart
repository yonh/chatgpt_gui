import 'package:chatgpt_gui/env/env.dart';
import 'package:flutter_tiktoken/flutter_tiktoken.dart';
import 'package:openai_api/openai_api.dart';

import '../models/message.dart';

class ChatGPTService {
  final client = OpenaiClient(
    config: OpenaiConfig(
      // apiKey: "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", // 你的key
      apiKey: Env.apiKey,
      // 如果有自建OpenAI服务请设置这里，如果你自己的代理服务器不太稳定，这里可以配置为 https://openai.mignsin.workers.dev/v1
      baseUrl: Env.baseUrl != null && Env.baseUrl.isNotEmpty
          ? Env.baseUrl
          : Constants.kBaseUrl,
      // 代理服务地址, 比如使用 clashx，你可以使用 http://127.0.0.1:7890
      httpProxy: Env.httpProxy,
    ),
  );

  Future<ChatCompletionResponse> sendChat(String content) async {
    final request = ChatCompletionRequest(model: Models.gpt3_5Turbo, messages: [
      ChatMessage(
        content: content,
        role: ChatMessageRole.user,
      )
    ]);
    return await client.sendChatCompletion(request);
  }

  Future streamChat(
    List<Message> messages, {
    Function(String text)? onSuccess,
  }) async {
    int tokenCount =
        calculateTokenCount(messages.toChatMessages(), Models.gpt3_5Turbo);

    print('Token count: $tokenCount');

    final request = ChatCompletionRequest(
        model: Models.gpt3_5Turbo,
        stream: true,
        messages: messages
            .map((e) => ChatMessage(
                  content: e.content,
                  role: e.isUser
                      ? ChatMessageRole.user
                      : ChatMessageRole.assistant,
                ))
            .toList()
            .limitMessages());
    return await client.sendChatCompletionStream(request, onSuccess: (p) {
      final text = p.choices.first.delta?.content;
      if (text != null) {
        onSuccess?.call(text);
      }
    });
  }

  int calculateTokenCount(List<ChatMessage> messages, String model) {
    final encoding = encodingForModel(model);
    var count = 0;
    for (var message in messages) {
      count +=
          encoding.encode(message.role.toString() + message.content).length;
    }
    return count;
  }
}

// 最大 token 限制
final maxTokens = {
  Models.gpt3_5Turbo: 4096,
  Models.gpt4: 8192,
};

extension on List<ChatMessage> {
  List<ChatMessage> limitMessages({String model = Models.gpt3_5Turbo}) {
    assert(maxTokens[model] != null, 'Model not supported');
    var messages = <ChatMessage>[];
    final encoding = encodingForModel(model);
    final maxToken = maxTokens[model]!;
    var count = 0;
    if (isEmpty) return messages;
    // 反向遍历 ChatMessage 列表。对于每条消息，它通过编码消息的角色和内容的连接来计算令牌数。
    // 如果总的令牌数不超过允许的最大令牌数，那么消息就会被插入到 messages 列表的开始。
    for (var i = length - 1; i >= 0; i--) {
      final m = this[i];
      count = count + encoding.encode(m.role.toString() + m.content).length;
      if (count <= maxToken) {
        messages.insert(0, m);
      }
    }
    return messages;
  }
}

extension on List<Message> {
  List<ChatMessage> toChatMessages() {
    return map(
      (e) => ChatMessage(
        content: e.content,
        role: e.isUser ? ChatMessageRole.user : ChatMessageRole.assistant,
      ),
    ).toList();
  }
}
