import 'dart:typed_data';
import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storage_client/storage_client.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ==== Auth ====
  Future<AuthResponse> signUp(String email, String password) async {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // ==== Storage ====
  Future<void> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
    bool upsert = true,
  }) async {
    final fileOptions = FileOptions(
      contentType: contentType ?? lookupMimeType(path) ?? 'application/octet-stream',
      upsert: upsert,
    );
    await _client.storage.from(bucket).uploadBinary(path, bytes, fileOptions: fileOptions);
  }

  Future<List<FileObject>> listFiles({
    required String bucket,
    String path = '',
  }) async {
    return _client.storage.from(bucket).list(path: path);
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ==== Helper para consultas del Tutor/Resumidor ====
  Future<void> uploadQueryLog({
    required String type, // 'tutor' | 'summarizer'
    required String prompt,
    String? response,
    String? level,
  }) async {
    final bucket = dotenv.env['SUPABASE_BUCKET'] ?? 'uploads';
    final userId = currentUser?.id ?? 'anon';
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final safeType = type.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    final path = '$userId/${ts}_${safeType}.txt';

    final sb = StringBuffer()
      ..writeln('Tipo: $type')
      ..writeln('Usuario: $userId')
      ..writeln('Fecha: $ts');
    if (level != null) sb.writeln('Nivel: $level');
    sb
      ..writeln('')
      ..writeln('Prompt:')
      ..writeln(prompt)
      ..writeln('')
      ..writeln('Respuesta:')
      ..writeln(response ?? '[sin respuesta]');

    final bytes = Uint8List.fromList(utf8.encode(sb.toString()));
    await uploadBytes(
      bucket: bucket,
      path: path,
      bytes: bytes,
      contentType: 'text/plain; charset=utf-8',
    );
  }
}