import 'package:flutter/material.dart';
import 'tutor_screen.dart';
import 'summarizer_screen.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor IA - Caso de Estudio'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.instance.signOut();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cards = <Widget>[
              _CardAction(
                title: 'Tutor (Chat)',
                subtitle: 'Haz preguntas y recibe explicaciones personalizadas.',
                icon: Icons.chat_bubble_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorScreen()),
                ),
              ),
              _CardAction(
                title: 'Resumidor',
                subtitle: 'Pega un texto y obtén un resumen adaptado.',
                icon: Icons.summarize_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SummarizerScreen()),
                ),
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Qué quieres hacer hoy?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: isWide
                      ? GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: cards,
                        )
                      : ListView.separated(
                          itemBuilder: (context, i) => cards[i],
                          separatorBuilder: (context, _) => const SizedBox(height: 12),
                          itemCount: cards.length,
                        ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Caso de estudio: Aprendizaje Personalizado con IA',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
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
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.onPrimaryContainer, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
