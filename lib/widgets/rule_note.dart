import 'package:flutter/material.dart';

class RuleNote extends StatelessWidget {
  final Map<String, dynamic> data;

  const RuleNote({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? '';
    final String content = data['content'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
