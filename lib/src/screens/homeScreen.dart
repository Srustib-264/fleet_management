import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = 'Dashboard';

  String _fullname = 'User';
  String _role = 'Admin';

  final List<Map<String, dynamic>> menus = [
    {
      'label': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'route': '/dashboard',
    },
    {
      'label': 'Settings',
      'icon': Icons.settings_outlined,
      'route': '/settings',
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncMenuWithRoute();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _fullname = prefs.getString('fullname') ?? 'User';
      _role = prefs.getString('role') ?? 'Admin';
    });
  }

  void _syncMenuWithRoute() {
    final currentPath = GoRouterState.of(context).uri.path;

    for (final menu in menus) {
      if (currentPath.startsWith(menu['route'])) {
        if (mounted) {
          setState(() {
            _selectedMenu = menu['label'];
          });
        }
        return;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncMenuWithRoute();
      }
    });
  }

  void _navigateTo(String label, String route) {
    setState(() {
      _selectedMenu = label;
    });

    context.go(route);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d151f),
      body: SafeArea(
        child: Column(
          children: [
            // ==============================
            // HEADER
            // ==============================
            _buildHeader(),

            // ==============================
            // MENU BAR
            // ==============================
            _buildMenuBar(),

            // ==============================
            // PAGE CONTENT
            // ==============================
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 62,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xff0d151f),
        border: Border(
          bottom: BorderSide(color: Color(0xff273444), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          // --------------------------
          // LOGO
          // --------------------------
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xff078df5).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xff078df5).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xff078df5),
                  size: 19,
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'TrakFleet',
                style: TextStyle(
                  color: Color(0xff078df5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // --------------------------
          // NOTIFICATION
          // --------------------------
          _buildHeaderIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),

          const SizedBox(width: 4),

          // --------------------------
          // USER
          // --------------------------
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            color: const Color(0xff18222e),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: SizedBox(
                    width: 190,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff078df5).withOpacity(0.12),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xff078df5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fullname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _role,
                                style: const TextStyle(
                                  color: Color(0xff8994a2),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const PopupMenuDivider(),

                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _role,
                      style: const TextStyle(
                        color: Color(0xff8994a2),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 5),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xff8994a2),
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER ICON
  // ============================================================

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  // ============================================================
  // MENU BAR
  // ============================================================

  Widget _buildMenuBar() {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xff0d151f),
        border: Border(
          bottom: BorderSide(color: Color(0xff273444), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),

          ...menus.map((menu) {
            final String label = menu['label'];
            final String route = menu['route'];
            final IconData icon = menu['icon'];

            final bool isSelected = _selectedMenu == label;

            return _buildMenuItem(
              label: label,
              icon: icon,
              isSelected: isSelected,
              onTap: () {
                _navigateTo(label, route);
              },
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xff078df5).withOpacity(0.06),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(color: Color(0xff078df5), width: 2),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xff078df5)
                    : const Color(0xffc2c9d1),
              ),

              const SizedBox(width: 5),

              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xff078df5)
                      : const Color(0xffc2c9d1),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
