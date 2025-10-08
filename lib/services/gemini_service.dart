import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService._();
  static final instance = GeminiService._();

  /// Modelos compatibles (evitar sufijo `-latest` y variantes 8b en v1beta).
  /// Ordenados por preferencia.
  static const List<String> _candidates = <String>[
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
  ];

  String _activeModel = _candidates.first;

  /// Construye el modelo con la API key cargada desde .env (siempre en el momento de uso).
  GenerativeModel _modelFor(String modelName) {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception('Falta GEMINI_API_KEY en .env');
    }
    return GenerativeModel(model: modelName, apiKey: key);
  }

  Future<String> ask(String prompt) async {
    final text = prompt.trim();
    if (text.isEmpty) return '[Sin pregunta]';
    return _generateWithFallback(text);
  }

  Future<String> summarize(String text, {String level = 'intermedio'}) async {
    final body = text.trim();
    if (body.isEmpty) return '[No hay texto para resumir]';

    final prompt =
        '''
Actúa como tutor. Resume el siguiente texto para un nivel "$level".
- Usa viñetas claras.
- Incluye un párrafo final con ideas clave.

Texto:
$body
''';

    return _generateWithFallback(prompt);
  }

  /// Intenta generar usando los modelos en [_candidates] con fallback automático.
  Future<String> _generateWithFallback(String prompt) async {
    Exception? lastErr;

    for (final name in _candidates) {
      try {
        final model = _modelFor(name);
        final resp = await model.generateContent([Content.text(prompt)]);
        _activeModel = name;
        final out = resp.text?.trim();
        if (out == null || out.isEmpty) {
          return '[Sin respuesta]';
        }
        return out;
      } catch (e) {
        // Errores típicos cuando el modelo no existe o no soporta el método.
        final msg = e.toString().toLowerCase();
        final isModelIssue =
            msg.contains('not found') ||
            msg.contains('not supported') ||
            msg.contains('unsupported') ||
            msg.contains('404');

        if (isModelIssue) {
          lastErr = e as Exception;
          // Intentar con el siguiente modelo.
          continue;
        } else {
          // Otros errores (cuota, red, auth...) -> propagar.
          rethrow;
        }
      }
    }

    throw Exception(
      'Ninguno de los modelos disponibles respondió. '
      'Último error: ${lastErr?.toString() ?? 'desconocido'}. '
      'Verifica tu clave, cuota o permisos del proyecto.',
    );
  }

  /// Útil si quieres mostrar el modelo actual en UI o logs.
  String get activeModel => _activeModel;
}
