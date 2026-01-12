import 'package:google_generative_ai/google_generative_ai.dart';
import '../mock_data.dart';

class ChatService {
  final String apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  ChatService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are an AR (Account Receivable) Assistant. '
        'Your goal is to help users manage their receivables efficiently. '
        'You have access to Client Wise, Bucket Wise, Age Wise, and Collection Projection reports. '
        'When a user asks about reports, explain what they are or suggest looking at them. '
        'Be professional, helpful, and concise. '
        'If the user asks for data, you can mention some mock companies like Acme Corp, Globex Inc, or Soylent Corp.',
      ),
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      return "Error connecting to AI: ${e.toString()}";
    }
  }

  Stream<GenerateContentResponse> sendMessageStream(String message) {
    return _chatSession.sendMessageStream(Content.text(message));
  }
}
