import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

class GeminiClient {
  final Dio dio;
  final String apiKey;

  GeminiClient(this.dio, this.apiKey);

  Future<Completion> createChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async {
    try {
      final contents = messages.map((m) => {
        'role': m.role,
        'parts': m.content is String
            ? [{'text': m.content}]
            : m.content,
      }).toList();

      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
      );

      if (response.data['candidates'] != null && 
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message,
      );
    }
  }

  Stream<String> streamChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async* {
    try {
      final contents = messages.map((m) => {
        'role': m.role,
        'parts': m.content is String
            ? [{'text': m.content}]
            : m.content,
      }).toList();

      final response = await dio.post(
        '/models/$model:streamGenerateContent',
        queryParameters: {
          'key': apiKey,
          'alt': 'sse',
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data as ResponseBody;
      await for (var line in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            if (json.containsKey('candidates') && 
                json['candidates'].isNotEmpty && 
                json['candidates'][0].containsKey('content') &&
                json['candidates'][0]['content'].containsKey('parts') &&
                json['candidates'][0]['content']['parts'].isNotEmpty) {
              final text = json['candidates'][0]['content']['parts'][0]['text'];
              if (text != null && text.isNotEmpty) {
                yield text;
              }
            }
          } catch (e) {
            // Skip malformed data
          }
        }
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message,
      );
    }
  }

  Future<Completion> createMultimodal({
    required String prompt,
    required File image,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
  }) async {
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    
    try {
      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': prompt
                },
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
          },
        },
      );

      if (response.data['candidates'] != null && 
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message,
      );
    }
  }

  Future<List<String>> listModels() async {
    try {
      final response = await dio.get(
        '/models',
        queryParameters: {
          'key': apiKey,
        },
      );
      
      final modelList = (response.data['models'] as List)
          .map((model) => model['name'] as String)
          .toList();
      return modelList;
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message ?? 'Failed to fetch models',
      );
    } catch (e) {
      throw GeminiException(
        statusCode: 500,
        message: 'Unexpected error fetching models: ${e.toString()}',
      );
    }
  }

  Future<Balance> getUserBalance() async {
    throw UnimplementedError('Gemini API does not support balance retrieval.');
  }
}

class Message {
  final String role;
  final dynamic content; // String or List<Map<String, dynamic>>

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class Balance {
  final String info;

  Balance({required this.info});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}