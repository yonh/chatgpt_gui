import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_api/openai_api.dart';

class ChatUiState {
  final bool requestLoading;
  final String model;
  final bool isModelConfirmed;

  ChatUiState(
      {this.requestLoading = false,
      this.model = Models.gpt3_5Turbo,
      this.isModelConfirmed = false});
}

class ChatUiStateProvider extends StateNotifier<ChatUiState> {
  ChatUiStateProvider() : super(ChatUiState());

  void setRequestLoading(bool loading) {
    state = ChatUiState(
        requestLoading: loading,
        model: state.model,
        isModelConfirmed: state.isModelConfirmed);
  }

  set model(String model) {
    state = ChatUiState(
      model: model,
      requestLoading: state.requestLoading,
      isModelConfirmed: state.isModelConfirmed,
    );
  }

  void confirmModel() {
    state = ChatUiState(
        isModelConfirmed: true,
        model: state.model,
        requestLoading: state.requestLoading);
  }
}

final chatUiStateProvider =
    StateNotifierProvider<ChatUiStateProvider, ChatUiState>(
  (ref) => ChatUiStateProvider(),
);
