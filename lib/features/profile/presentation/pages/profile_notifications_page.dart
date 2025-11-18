import 'package:flutter/material.dart';

class ProfileNotificationsPage extends StatelessWidget {
  const ProfileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _mockNotifications;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              'Vaciar',
              style: TextStyle(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
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
    final isRecent = notification.relativeTime == 'Ahora' || 
                     notification.relativeTime.startsWith('Hace');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: isRecent
            ? Border.all(
                color: const Color(0xFF7209B7).withOpacity(0.2),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: isRecent
                  ? const Color(0xFF7209B7)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (notification.dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notification.dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isRecent
                  ? const Color(0xFF7209B7).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notification.relativeTime,
              style: TextStyle(
                fontSize: 11,
                color: isRecent
                    ? const Color(0xFF7209B7)
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
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