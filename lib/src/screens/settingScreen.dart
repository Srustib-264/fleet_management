import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'CRUDScreens/goupCRUDScreen.dart';
import 'CRUDScreens/orgCRUDScreen.dart';
import 'CRUDScreens/roleCRUDScreen.dart';
import 'CRUDScreens/userCRUDScreen.dart';

class SettingsScreen extends StatelessWidget {
  final String initialTab;

  const SettingsScreen({super.key, this.initialTab = 'users'});

  static const Color backgroundColor = Color(0xff252b33);
  static const Color panelColor = Color(0xff202b39);
  static const Color primaryBlue = Color(0xff078df5);

  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xff8994a2);
  static const Color mutedText = Color(0xff697482);

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    final bool isUsers = currentPath == '/settings/users';
    final bool isGroups = currentPath == '/settings/groups';
    final bool isOrgs = currentPath == '/settings/orgs';
    final bool isRoles = currentPath == '/settings/roles';
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Container(
                width: 230,

                decoration: BoxDecoration(
                  color: panelColor,

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(color: Colors.white.withOpacity(0.05)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),

                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,

                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.10),

                              borderRadius: BorderRadius.circular(8),

                              border: Border.all(
                                color: primaryBlue.withOpacity(0.18),
                              ),
                            ),

                            child: const Icon(
                              Icons.settings_outlined,
                              size: 17,
                              color: primaryBlue,
                            ),
                          ),

                          const SizedBox(width: 11),

                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.white.withOpacity(0.06)),

                    const SizedBox(height: 14),

                    // ------------------------------------------
                    // GENERAL LABEL
                    // ------------------------------------------
                    const Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 8),

                      child: Text(
                        'GENERAL',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    _buildSettingsItem(
                      title: 'Users',
                      icon: Icons.person_outline,
                      selected: isUsers,

                      onTap: () {
                        context.go('/settings/users');
                      },
                    ),

                    _buildSettingsItem(
                      title: 'Organizations',
                      icon: Icons.groups_outlined,
                      selected: isOrgs,

                      onTap: () {
                        context.go('/settings/orgs');
                      },
                    ),
                    _buildSettingsItem(
                      title: 'Roles',
                      icon: Icons.admin_panel_settings_outlined,
                      selected: isRoles,

                      onTap: () {
                        context.go('/settings/roles');
                      },
                    ),
                    _buildSettingsItem(
                      title: 'Groups',
                      icon: Icons.groups_outlined,
                      selected: isGroups,

                      onTap: () {
                        context.go('/settings/groups');
                      },
                    ),
                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(18),

                      child: Text(
                        'TrakFleet Management Portal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: panelColor,

                    borderRadius: BorderRadius.circular(8),

                    border: Border.all(color: Colors.white.withOpacity(0.05)),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(28),

                    child: _buildContent(
                      isUsers: isUsers,
                      isGroups: isGroups,
                      isOrgs: isOrgs,
                      isRoles: isRoles,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(8),

          hoverColor: Colors.white.withOpacity(0.025),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),

            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

            decoration: BoxDecoration(
              color: selected
                  ? primaryBlue.withOpacity(0.10)
                  : Colors.transparent,

              borderRadius: BorderRadius.circular(8),

              border: Border.all(
                color: selected
                    ? primaryBlue.withOpacity(0.12)
                    : Colors.transparent,
              ),
            ),

            child: Row(
              children: [
                Icon(
                  icon,

                  size: 17,

                  color: selected ? primaryBlue : secondaryText,
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    title,

                    style: TextStyle(
                      color: selected ? Colors.white : secondaryText,

                      fontSize: 11,

                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 4,
                    height: 4,

                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool isUsers,
    required bool isGroups,
    required bool isOrgs,
    required bool isRoles,
  }) {
    if (isUsers) {
      return const UserCRUDScreen();
    }

    if (isGroups) {
      return const GroupCRUDScreen();
    }
    if (isOrgs) {
      return const OrgCRUDScreen();
    }
    if (isRoles) {
      return const RoleCRUDScreen();
    }
    return const SizedBox();
  }
}

class UsersContent extends StatelessWidget {
  const UsersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Users',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),

            borderRadius: BorderRadius.circular(8),

            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),

          child: const Text(
            'Users content',
            style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class GroupsContent extends StatelessWidget {
  const GroupsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Groups',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),

            borderRadius: BorderRadius.circular(8),

            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),

          child: const Text(
            'Groups content',
            style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class OrgsContent extends StatelessWidget {
  const OrgsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Orgs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),

            borderRadius: BorderRadius.circular(8),

            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),

          child: const Text(
            'Orgs content',
            style: TextStyle(color: Color(0xff8994a2), fontSize: 11),
          ),
        ),
      ],
    );
  }
}
