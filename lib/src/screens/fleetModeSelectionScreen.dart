import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FleetModeSelectionPage extends StatefulWidget {
  const FleetModeSelectionPage({super.key});

  @override
  State<FleetModeSelectionPage> createState() => _FleetModeSelectionPageState();
}

class _FleetModeSelectionPageState extends State<FleetModeSelectionPage> {
  String? hoveredMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101821),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Fleet Mode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Choose the fleet environment you want to manage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff8994a2), fontSize: 13),
                ),

                const SizedBox(height: 38),

                // =================================================
                // FLEET CARDS
                // =================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFleetCard(
                        mode: 'ICE',
                        title: 'ICE Fleet',
                        subtitle: 'Internal Combustion Engine',
                        description:
                            'Manage conventional vehicles, drivers, trips and fleet operations.',
                        icon: Icons.local_shipping_outlined,
                        onTap: () {
                          context.go('/dashboard');
                        },
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: _buildFleetCard(
                        mode: 'EV',
                        title: 'EV Fleet',
                        subtitle: 'Electric Vehicles',
                        description:
                            'Manage electric vehicles, charging operations and EV fleet data.',
                        icon: Icons.electric_car_outlined,
                        onTap: () {
                          context.go('/dashboard');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FLEET CARD
  // =============================================================

  Widget _buildFleetCard({
    required String mode,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isHovered = hoveredMode == mode;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          hoveredMode = mode;
        });
      },

      onExit: (_) {
        setState(() {
          hoveredMode = null;
        });
      },

      child: GestureDetector(
        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          curve: Curves.easeOut,

          padding: const EdgeInsets.all(28),

          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xff182535)
                : const Color(0xff151f2b),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: isHovered
                  ? const Color(0xff078df5)
                  : Colors.white.withOpacity(0.07),

              width: 1,
            ),

            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xff078df5).withOpacity(0.10),
                      blurRadius: 25,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // ICON
              // =================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: isHovered
                      ? const Color(0xff078df5).withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  size: 29,
                  color: isHovered
                      ? const Color(0xff078df5)
                      : const Color(0xff8994a2),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // TITLE
              // =================================================
              Text(
                title,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,

                style: TextStyle(
                  color: isHovered
                      ? const Color(0xff078df5)
                      : const Color(0xff8994a2),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // DESCRIPTION
              // =================================================
              SizedBox(
                height: 42,

                child: Text(
                  description,

                  style: const TextStyle(
                    color: Color(0xff697482),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // SELECT BUTTON
              // =================================================
              Row(
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: isHovered
                          ? const Color(0xff078df5)
                          : const Color(0xff8994a2),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 7),

                  AnimatedPadding(
                    duration: const Duration(milliseconds: 180),

                    padding: EdgeInsets.only(left: isHovered ? 5 : 0),

                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: isHovered
                          ? const Color(0xff078df5)
                          : const Color(0xff8994a2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
