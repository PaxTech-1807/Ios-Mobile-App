import 'package:flutter/material.dart';

class EmptyServicePlaceholder extends StatelessWidget {
  const EmptyServicePlaceholder({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.design_services_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin servicios registrados',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tus servicios para que tus clientes sepan lo que ofreces.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onAddPressed,
              child: const Text('+ Nuevo servicio'),
            ),
          ],
        ),
      ),
    );
  }
}
