import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Dashboard',

            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Overview of your fleet operations',

            style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Total Vehicles',
                  value: '0',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildCard(
                  icon: Icons.person_outline,
                  title: 'Total Drivers',
                  value: '0',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildCard(
                  icon: Icons.route_outlined,
                  title: 'Active Trips',
                  value: '0',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildCard(
                  icon: Icons.groups_outlined,
                  title: 'Groups',
                  value: '0',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,

                  child: _buildLargeCard(
                    title: 'Recent Activity',

                    child: const Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(
                          color: Color(0xff697482),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _buildLargeCard(
                    title: 'Fleet Status',

                    child: const Center(
                      child: Text(
                        'No fleet data available',
                        style: TextStyle(
                          color: Color(0xff697482),
                          fontSize: 11,
                        ),
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xff151f2b),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xff078df5).withOpacity(0.10),

              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(icon, color: const Color(0xff078df5), size: 20),
          ),

          const SizedBox(width: 13),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(color: Color(0xff8994a2), fontSize: 10),
              ),

              const SizedBox(height: 5),

              Text(
                value,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xff151f2b),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          Divider(height: 1, color: Colors.white.withOpacity(0.06)),

          Expanded(child: child),
        ],
      ),
    );
  }
}
