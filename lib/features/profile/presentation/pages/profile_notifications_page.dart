import 'package:flutter/material.dart';

class ProfileNotificationsPage extends StatelessWidget {
  const ProfileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _mockNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            label: const Text('Vaciar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _NotificationTile(notification: item);
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final _ProfileNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (notification.dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notification.dateLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            notification.relativeTime,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNotification {
  const _ProfileNotification({
    required this.message,
    required this.relativeTime,
    required this.dateLabel,
  });

  final String message;
  final String relativeTime;
  final String dateLabel;
}

const _mockNotifications = [
  _ProfileNotification(
    message: 'Luis G. tiene una cita en 15 minutos. No olvides prepararte.',
    relativeTime: 'Ahora',
    dateLabel: '',
  ),
  _ProfileNotification(
    message:
        'Nicolas A. canceló su cita de Corte simple. Viernes 18/04 – 10:00 a.m.',
    relativeTime: 'Hace 3h',
    dateLabel: '',
  ),
  _ProfileNotification(
    message:
        'Matías L. reprogramó su cita de Corte simple. Del 15/04 3:00 p.m. → 16/04 2:30 p.m.',
    relativeTime: 'Ayer',
    dateLabel: 'Ayer',
  ),
  _ProfileNotification(
    message:
        'Has alcanzado el 90% de tu límite de citas. (Plan ProStyle)',
    relativeTime: 'Ayer',
    dateLabel: 'Ayer',
  ),
  _ProfileNotification(
    message:
        'Mejora a Pro+. Categorías ilimitadas y analíticas.',
    relativeTime: '05/04',
    dateLabel: '05/04',
  ),
  _ProfileNotification(
    message:
        'Emilia reservó tratamiento de keratina. Martes 08/04 – 3:00 p.m.',
    relativeTime: '05/01',
    dateLabel: '05/01',
  ),
];