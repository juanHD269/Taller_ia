import 'package:flutter/material.dart';
import 'tutor_screen.dart';
import 'summarizer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor IA - Caso de Estudio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardAction(
              title: 'Tutor (Chat)',
              subtitle: 'Haz preguntas y recibe explicaciones personalizadas.',
              icon: Icons.chat_bubble_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _CardAction(
              title: 'Resumidor',
              subtitle: 'Pega un texto y obtén un resumen adaptado.',
              icon: Icons.summarize_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummarizerScreen()),
              ),
            ),
            const Spacer(),
            const Text(
              'Caso de estudio: Aprendizaje Personalizado con IA',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _CardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
