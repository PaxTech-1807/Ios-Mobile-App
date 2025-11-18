import 'package:flutter/material.dart';

class ProfileSubscriptionPage extends StatelessWidget {
  const ProfileSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Suscripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Plan Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7209B7),
                    Color(0xFF9D4EDD),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7209B7).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Plan Actual',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ProStyle',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Renovación: 15 de Mayo, 2024',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Usage Stats
            _UsageCard(
              title: 'Uso del plan',
              items: [
                _UsageItem(
                  label: 'Citas este mes',
                  value: '450 / 500',
                  progress: 0.9,
                  color: const Color(0xFF7209B7),
                ),
                const SizedBox(height: 16),
                _UsageItem(
                  label: 'Servicios activos',
                  value: '12 / 15',
                  progress: 0.8,
                  color: const Color(0xFF9D4EDD),
                ),
                const SizedBox(height: 16),
                _UsageItem(
                  label: 'Trabajadores',
                  value: '8 / 10',
                  progress: 0.8,
                  color: const Color(0xFF7209B7),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Available Plans
            const Text(
              'Planes disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              name: 'Básico',
              price: '\$29/mes',
              features: [
                'Hasta 200 citas/mes',
                '5 servicios',
                '3 trabajadores',
                'Soporte por email',
              ],
              isRecommended: false,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              name: 'ProStyle',
              price: '\$59/mes',
              features: [
                'Hasta 500 citas/mes',
                '15 servicios',
                '10 trabajadores',
                'Soporte prioritario',
                'Analíticas básicas',
              ],
              isRecommended: true,
              isCurrent: true,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              name: 'Pro+',
              price: '\$99/mes',
              features: [
                'Citas ilimitadas',
                'Servicios ilimitados',
                'Trabajadores ilimitados',
                'Soporte 24/7',
                'Analíticas avanzadas',
                'Integraciones',
              ],
              isRecommended: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
}

class _UsageItem extends StatelessWidget {
  const _UsageItem({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    this.isRecommended = false,
    this.isCurrent = false,
  });

  final String name;
  final String price;
  final List<String> features;
  final bool isRecommended;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRecommended
            ? Border.all(
                color: const Color(0xFF7209B7),
                width: 2,
              )
            : Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isRecommended
                ? const Color(0xFF7209B7).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7209B7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Actual',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7209B7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              if (isRecommended && !isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7209B7),
                        Color(0xFF9D4EDD),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Recomendado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: const Color(0xFF7209B7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (!isCurrent) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7209B7),
                  side: const BorderSide(color: Color(0xFF7209B7)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cambiar a este plan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

