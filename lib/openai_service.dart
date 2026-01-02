import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = "YOUR_OPENAI_API_KEY";
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> generateProposal({
    required String name,
    required String client,
    required String role,
    required String experience,
  }) async {
    final prompt = '''
Write a concise, professional freelance proposal for the role of "$role" with $experience years of experience, addressed to client "$client", and written by freelancer "$name".
Keep the tone persuasive and friendly.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant that writes high-quality freelancer proposals."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices'][0]['message']['content'];
        return text.trim();
      } else {
        print("OpenAI API Error: ${response.statusCode} ${response.body}");
        return 'Failed to generate proposal. Please try again.';
      }
    } catch (e) {
      print("OpenAI Exception: $e");
      return 'Error occurred while generating proposal.';
    }
  }
}


