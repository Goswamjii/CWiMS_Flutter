import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router_service.dart';
import 'edit_router_screen.dart';

class RouterDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> router;

  const RouterDetailsScreen({
    super.key,
    required this.router,
  });

  @override
  ConsumerState<RouterDetailsScreen> createState() =>
      _RouterDetailsScreenState();
}

class _RouterDetailsScreenState
    extends ConsumerState<RouterDetailsScreen> {
  int? connectedDevices;
  bool isLoadingDevices = true;

  Map<String, dynamic>? networkHealth;
  bool isLoadingHealth = true;
  Map<String, dynamic>? todayHealth;
  bool isLoadingTodayHealth = true;

  @override
  void initState() {
    super.initState();
    loadDeviceCount();
    loadNetworkHealth();
    loadTodayHealth();
  }

  Future<void> loadTodayHealth() async {
    try {
      final response = await ref
          .read(routerServiceProvider)
          .getTodayNetworkHealth(widget.router['id']);

      if (mounted) {
        setState(() {
          todayHealth = Map<String, dynamic>.from(response.data);
          isLoadingTodayHealth = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTodayHealth = false;
        });
      }
    }
  }

  Future<void> loadDeviceCount() async {
    try {
      final response = await ref
          .read(routerServiceProvider)
          .getDeviceCount(widget.router['id']);

      if (mounted) {
        setState(() {
          connectedDevices = response.data['connectedDevices'];
          isLoadingDevices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDevices = false;
        });
      }
    }
  }

  Future<void> loadNetworkHealth() async {
    try {
      final response = await ref
          .read(routerServiceProvider)
          .getNetworkHealth(widget.router['id']);

      if (mounted) {
        setState(() {
          networkHealth = Map<String, dynamic>.from(response.data);
          debugPrint('NETWORK HEALTH RESPONSE: ${response.data}');
          isLoadingHealth = false;
        });
      }
    } catch (e) {
      debugPrint('NETWORK HEALTH ERROR: $e');

      if (mounted) {
        setState(() {
          isLoadingHealth = false;
        });
      }
    }
  }

  String getLastChecked() {
    final value = networkHealth?['lastCheckedAt'];

    if (value == null) {
      return '—';
    }

    try {
      String dateString = value.toString();

      // SQL Server can return the UTC DateTime without the "Z".
      // Treat such values as UTC before converting to the phone's local time.
      if (!dateString.endsWith('Z') &&
          !RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(dateString)) {
        dateString = '${dateString}Z';
      }

      final dateTime = DateTime.parse(dateString).toLocal();

      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.router,
                size: 80,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 24),

            _detailCard(
              'Router ID',
              widget.router['id']?.toString() ?? '—',
            ),

            _detailCard(
              'Router Name',
              widget.router['routerName'] ?? '—',
            ),

            _detailCard(
              'Wi-Fi Name (SSID)',
              widget.router['ssid'] ?? '—',
            ),

            _detailCard(
              'MAC Address',
              widget.router['macAddress'] ?? '—',
            ),

            _detailCard(
              'IP Address',
              widget.router['ipAddress'] ?? '—',
            ),

            _detailCard(
              'Location',
              widget.router['location'] ?? '—',
            ),

            _detailCard(
              'Status',
              widget.router['status'] ?? '—',
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Network Health',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: isLoadingHealth
                            ? null
                            : () async {
                          setState(() {
                            isLoadingHealth = true;
                            isLoadingTodayHealth = true;
                          });

                          try {
                            await ref
                                .read(routerServiceProvider)
                                .checkNetworkHealth(
                              widget.router['id'],
                            );

                            await loadNetworkHealth();
                            await loadTodayHealth();
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                isLoadingHealth = false;
                                isLoadingTodayHealth = false;
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Health check failed: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                        ),
                        label: const Text('Check'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLoadingHealth
                              ? Colors.orange
                              : networkHealth?['isOnline'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLoadingHealth
                            ? 'Checking...'
                            : networkHealth?['isOnline'] == true
                            ? 'Online'
                            : 'Offline',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isLoadingHealth
                        ? 'Checking router connectivity...'
                        : networkHealth?['wifiStatus'] ?? '—',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (isLoadingTodayHealth)
                    Text(
                      "Loading today's health...",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    )
                  else ...[
                    Text(
                      '${todayHealth?['healthPercentage'] ?? 0}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Healthy Today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 17,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLoadingHealth
                            ? 'Checking...'
                            : 'Last checked: ${getLastChecked()}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _detailCard(
              'Connected Devices',
              isLoadingDevices
                  ? 'Loading...'
                  : connectedDevices?.toString() ?? '—',
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditRouterScreen(
                            router: widget.router,
                          ),
                        ),
                      );

                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Router'),
                            content: const Text(
                              'Are you sure you want to delete this router?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true) return;

                      try {
                        await ref
                            .read(routerServiceProvider)
                            .deleteRouter(widget.router['id']);

                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to delete router: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(value),
        ),
      ),
    );
  }
}
