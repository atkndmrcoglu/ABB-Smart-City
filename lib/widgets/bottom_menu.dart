import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.22, 
      minChildSize: 0.22,    
      maxChildSize: 0.85,     
      snap: true,             
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Sliding Chevron Indicator
              const SizedBox(height: 12),
              Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey[400], size: 28),
              
              // 2. Title Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Tıkla ve Hizmetleri Gör',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF00B48B), // Custom green matching the style
                  ),
                ),
              ),

              // 3. Category Tabs Layout Tracker
              
              const Divider(height: 1, thickness: 1),

              // 4. Scrollable Dynamic Grid Matrix
              Expanded(
                child: GridView.builder(
                  controller: scrollController, // Vital connection for drag controls
                  padding: const EdgeInsets.all(16.0),
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95, // Adjust vertical box size squeeze
                  ),
                  itemBuilder: (context, index) {
                    final items = [
                      {'title': 'OTOBÜSLER', 'icon': Icons.bus_alert, 'color': Colors.red},
                      {'title': 'ECZANELER', 'icon': Icons.local_pharmacy, 'color': Colors.blue},
                      {'title': 'KENTKART DOLUM NOKTALARI', 'icon': Icons.card_membership, 'color': Colors.cyan},
                      {'title': 'KENTKART İŞLEMLERİ', 'icon': Icons.cast_rounded, 'color': Colors.purple},
                      {'title': 'COV HAVALİMANI SERVİSLER', 'icon': Icons.airplane_ticket, 'color': Colors.orange},
                      {'title': 'MEZARLIK', 'icon': Icons.arrow_forward, 'color': Colors.green},
                    ];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(items[index]['icon'] as IconData, size: 55, color: items[index]['color'] as Color),
                          const SizedBox(height: 12),
                          Text(
                            items[index]['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String title;
  final bool isActive;
  const _CategoryTab({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Color(0xFF5E35B1), width: 2)) : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color(0xFF00B48B) : Colors.grey[600],
        ),
      ),
    );
  }
}