import 'package:flutter/material.dart';
import '../../../../domain/entities/church.dart';

class ChurchActionButtons extends StatelessWidget {
  final Church church;
  final VoidCallback onGetDirections;
  final VoidCallback onContactChurch;
  final VoidCallback? onVisitWebsite;

  const ChurchActionButtons({
    super.key,
    required this.church,
    required this.onGetDirections,
    required this.onContactChurch,
    this.onVisitWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Get Directions
          Expanded(
            child: _ActionButton(
              icon: Icons.directions,
              label: 'Directions',
              onTap: onGetDirections,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          // Contact Church
          Expanded(
            child: _ActionButton(
              icon: Icons.phone,
              label: 'Contact',
              onTap: onContactChurch,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          // Website (if available)
          if (onVisitWebsite != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.language,
                label: 'Website',
                onTap: onVisitWebsite!,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
