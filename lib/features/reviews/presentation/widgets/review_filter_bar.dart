import 'package:flutter/material.dart';

class ReviewFilterBar extends StatelessWidget {
  const ReviewFilterBar({
    super.key,
    required this.selectedRating,
    required this.selectedSort,
    required this.onRatingChanged,
    required this.onSortChanged,
  });

  final int? selectedRating;
  final String? selectedSort;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String?> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filtro por rating
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedRating,
                      isDense: true,
                      isExpanded: false,
                      hint: Text(
                        'Todas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('Todas', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const DropdownMenuItem<int?>(
                          value: 5,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('5★', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const DropdownMenuItem<int?>(
                          value: 4,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('4+★', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const DropdownMenuItem<int?>(
                          value: 3,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('3+★', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const DropdownMenuItem<int?>(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('2+★', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const DropdownMenuItem<int?>(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                              SizedBox(width: 4),
                              Text('1+★', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: onRatingChanged,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Filtro por tiempo
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedSort,
                      isDense: true,
                      isExpanded: false,
                      hint: Text(
                        'Todos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos', style: TextStyle(fontSize: 12)),
                        ),
                        const DropdownMenuItem<String?>(
                          value: 'week',
                          child: Text('Hace 1 semana', style: TextStyle(fontSize: 12)),
                        ),
                        const DropdownMenuItem<String?>(
                          value: 'month',
                          child: Text('Hace 1 mes', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      onChanged: onSortChanged,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

