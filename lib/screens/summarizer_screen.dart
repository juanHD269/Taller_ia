import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';

class SummarizerScreen extends StatefulWidget {
  const SummarizerScreen({super.key});

  @override
  State<SummarizerScreen> createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends State<SummarizerScreen> {
  final _input = TextEditingController();
  String _level = 'intermedio';
  String? _output;
  bool _loading = false;

  Future<void> _summarize() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _output = null;
    });
    try {
      final s = await GeminiService.instance.summarize(text, level: _level);
      setState(() => _output = s);
      // Subir consulta y resultado como .txt a Storage
      try {
        await SupabaseService.instance.uploadQueryLog(
          type: 'summarizer',
          prompt: text,
          response: s,
          level: _level,
        );
      } catch (e) {
        // No bloqueamos la UI si falla la subida; avisamos.
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('No se pudo guardar en Storage: $e')));
        }
      }
    } catch (e) {
      setState(() => _output = '⚠️ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumidor IA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                const Text('Nivel: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _level,
                  items: const [
                    DropdownMenuItem(value: 'básico', child: Text('Básico')),
                    DropdownMenuItem(
                      value: 'intermedio',
                      child: Text('Intermedio'),
                    ),
                    DropdownMenuItem(
                      value: 'avanzado',
                      child: Text('Avanzado'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _level = v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _input,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: 'Pega aquí el texto a resumir…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _summarize,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.summarize),
              label: const Text('Resumir'),
            ),
            const SizedBox(height: 16),
            if (_output != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(_output!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
