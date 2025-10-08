/// Modelo que representa un mensaje del chat (usuario o IA).
///
/// Esta clase se usa en las pantallas del tutor inteligente o del resumidor
/// para mostrar cada mensaje en la conversación con su texto, tipo y hora.
class ChatMessage {
  /// Texto del mensaje (contenido del usuario o la IA).
  final String text;

  /// Indica si el mensaje fue enviado por el usuario (true) o por la IA (false).
  final bool isUser;

  /// Marca temporal del mensaje (fecha y hora).
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Convierte el mensaje a un mapa (útil si luego guardas el chat en Firestore o SQLite).
  Map<String, dynamic> toMap() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Crea una instancia a partir de un mapa.
  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    text: map['text'] ?? '',
    isUser: map['isUser'] ?? false,
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
  );
}
