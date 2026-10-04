import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/auth_screen.dart';
import '../router/router_screen.dart';
import '../router/router_service.dart';
import '../router/network_map_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool isLoading = true;
  List<dynamic> routers = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final response =
      await ref.read(routerServiceProvider).getMyRouters();

      if (!mounted) return;

      setState(() {
        routers = response.data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  int get onlineRouters {
    return routers.where((router) {
      return (router['status'] ?? '')
          .toString()
          .toLowerCase() ==
          'online';
    }).length;
  }

  int get offlineRouters {
    return routers.where((router) {
      return (router['status'] ?? '')
          .toString()
          .toLowerCase() ==
          'offline';
    }).length;
  }

  int get mappedRouters {
    return routers.where((router) {
      return router['latitude'] != null &&
          router['longitude'] != null;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'CWiMS Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();

              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const AuthScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------
              // GREETING
              // ----------------------------------------------------------

              Text(
                'Welcome back, $userName 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14213D),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Manage and monitor your Wi-Fi infrastructure',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF68748A),
                ),
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------------
              // SUMMARY CARDS - ROW 1
              // ----------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.router_rounded,
                      title: 'Total Routers',
                      value: isLoading
                          ? '...'
                          : routers.length.toString(),
                      subtitle: 'All registered routers',
                      iconBackground:
                      const Color(0xFFE4EEFF),
                      iconColor:
                      const Color(0xFF1677FF),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _summaryCard(
                      icon: Icons.wifi_rounded,
                      title: 'Online Routers',
                      value: isLoading
                          ? '...'
                          : onlineRouters.toString(),
                      subtitle: 'Currently active',
                      iconBackground:
                      const Color(0xFFE3FAF1),
                      iconColor:
                      const Color(0xFF08B979),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ----------------------------------------------------------
              // SUMMARY CARDS - ROW 2
              // ----------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.wifi_off_rounded,
                      title: 'Offline Routers',
                      value: isLoading
                          ? '...'
                          : offlineRouters.toString(),
                      subtitle: 'Need attention',
                      iconBackground:
                      const Color(0xFFFFE8EA),
                      iconColor:
                      const Color(0xFFF0444F),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _summaryCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Routers with Issues',
                      value: '—',
                      subtitle: 'Health monitoring',
                      iconBackground:
                      const Color(0xFFFFF0DD),
                      iconColor:
                      const Color(0xFFFF8A00),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ----------------------------------------------------------
              // MY NETWORK
              // ----------------------------------------------------------

              const Text(
                'My Network',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14213D),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Latest routers from your network',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF68748A),
                ),
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RouterScreen(),
                      ),
                    );

                    loadDashboardData();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View All Routers  ›',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------------------
              // ROUTER LIST
              // ----------------------------------------------------------

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (routers.isEmpty)
                _emptyRouterCard()
              else
                ...routers
                    .take(3)
                    .map(
                      (router) => _routerCard(router),
                ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // NETWORK MAP
              // ----------------------------------------------------------

              _networkMapCard(),

              const SizedBox(height: 20),

              // ----------------------------------------------------------
              // NETWORK OVERVIEW
              // ----------------------------------------------------------

              _networkOverviewCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SUMMARY CARD
  // ----------------------------------------------------------

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EAF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF68748A),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A95A8),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ROUTER CARD
  // ----------------------------------------------------------

  Widget _routerCard(
      Map<String, dynamic> router,
      ) {
    final status =
    (router['status'] ?? 'Unknown').toString();

    final isOnline =
        status.toLowerCase() == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EAF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: isOnline
                ? const Color(0xFFE5F7F0)
                : const Color(0xFFEAF0F8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.router_rounded,
            color: isOnline
                ? const Color(0xFF08B979)
                : const Color(0xFF5D6B82),
            size: 27,
          ),
        ),

        title: Text(
          router['routerName'] ??
              'Unnamed Router',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF14213D),
          ),
        ),

        subtitle: Padding(
          padding:
          const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Color(0xFF7C8799),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      router['location'] ?? '—',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF68748A),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.wifi_rounded,
                    size: 15,
                    color: Color(0xFF7C8799),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      router['ssid'] ?? '—',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF68748A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        trailing: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFE3FAF1)
                    : const Color(0xFFFFE8EA),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF08B979)
                          : const Color(0xFFF0444F),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                      color: isOnline
                          ? const Color(0xFF08A86F)
                          : const Color(0xFFE53945),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8995A8),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY ROUTER
  // ----------------------------------------------------------

  Widget _emptyRouterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EAF3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.router_outlined,
            size: 48,
            color: Color(0xFF9AA6B8),
          ),

          const SizedBox(height: 12),

          const Text(
            'No routers added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add a router to start managing your network.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF68748A),
            ),
          ),

          const SizedBox(height: 14),

          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RouterScreen(),
                ),
              );

              loadDashboardData();
            },
            child: const Text('Add Router'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // NETWORK MAP CARD
  // ----------------------------------------------------------

  Widget _networkMapCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1677FF),
            Color(0xFF4A9BFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
            const Color(0xFF1677FF)
                .withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(0.18),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Map',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'View your router locations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(0.16),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  '$mappedRouters mapped',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(15),
              border: Border.all(
                color:
                Colors.white.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'See router coverage and locations in one place.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Material(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const NetworkMapScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            'Open',
                            style: TextStyle(
                              color:
                              Color(0xFF1677FF),
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            color:
                            Color(0xFF1677FF),
                            size: 16,
                          ),
                        ],
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

  // ----------------------------------------------------------
  // NETWORK OVERVIEW
  // ----------------------------------------------------------

  Widget _networkOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF3FF),
            Color(0xFFF5F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD5E5FF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: Color(0xFF1677FF),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(0xFF14213D),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Quick summary of your network status',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        Color(0xFF68748A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _overviewValue(
                'Total',
                isLoading
                    ? '...'
                    : routers.length.toString(),
              ),

              _verticalDivider(),

              _overviewValue(
                'Online',
                isLoading
                    ? '...'
                    : onlineRouters.toString(),
              ),

              _verticalDivider(),

              _overviewValue(
                'Offline',
                isLoading
                    ? '...'
                    : offlineRouters.toString(),
              ),

              _verticalDivider(),

              _overviewValue(
                'Issues',
                '—',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // OVERVIEW VALUE
  // ----------------------------------------------------------

  Widget _overviewValue(
      String title,
      String value,
      ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF68748A),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // VERTICAL DIVIDER
  // ----------------------------------------------------------

  Widget _verticalDivider() {
    return Container(
      height: 38,
      width: 1,
      color: const Color(0xFFD2DEEF),
    );
  }
}