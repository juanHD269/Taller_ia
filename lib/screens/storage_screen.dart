import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:storage_client/storage_client.dart';
import '../services/supabase_service.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _bucket = dotenv.env['SUPABASE_BUCKET'] ?? 'uploads';
  bool _loading = false;
  List<FileObject> _files = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    try {
      final files = await SupabaseService.instance.listFiles(bucket: _bucket);
      setState(() => _files = files);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error listando archivos: $e')));
    }
  }

  Future<void> _pickAndUpload() async {
    setState(() => _loading = true);
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No se pudo leer el archivo')));
        return;
      }

      final userId = SupabaseService.instance.currentUser?.id ?? 'anon';
      final name = file.name;
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$name';

      await SupabaseService.instance.uploadBytes(
        bucket: _bucket,
        path: path,
        bytes: bytes,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Subido: $name')));
      await _refreshList();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al subir: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage (Supabase)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Bucket: '),
                Text(_bucket, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loading ? null : _pickAndUpload,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: const Text('Subir archivo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: ListView.separated(
                  itemCount: _files.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final f = _files[i];
                    final url = SupabaseService.instance
                        .getPublicUrl(bucket: _bucket, path: f.name);
                    return ListTile(
                      title: Text(f.name),
                      subtitle: Text(url),
                      leading: const Icon(Icons.insert_drive_file),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}