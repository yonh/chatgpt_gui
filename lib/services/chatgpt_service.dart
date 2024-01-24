import 'package:chatgpt_gui/env/env.dart';
import 'package:openai_api/openai_api.dart';

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
}
