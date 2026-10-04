import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router_service.dart';
import 'add_router_screen.dart';
import 'router_details_screen.dart';

class RouterScreen extends ConsumerStatefulWidget {
  const RouterScreen({super.key});

  @override
  ConsumerState<RouterScreen> createState() => _RouterScreenState();
}

class _RouterScreenState extends ConsumerState<RouterScreen> {
  bool isLoading = true;
  String message = '';
  List<dynamic> routers = [];

  @override
  void initState() {
    super.initState();
    loadRouters();
  }

  Future<void> loadRouters() async {
    try {
      final response =
      await ref.read(routerServiceProvider).getMyRouters();

      setState(() {
        routers = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddRouterScreen(),
                ),
              );

              if (result == true) {
                loadRouters();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : routers.isEmpty
          ? const Center(
        child: Text('No Routers Found'),
      )
          : ListView.builder(
        itemCount: routers.length,
        itemBuilder: (context, index) {
          final router = routers[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              onTap: () async {
                final result =
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RouterDetailsScreen(
                      router: router,
                    ),
                  ),
                );

                if (result == true) {
                  loadRouters();
                }
              },
              title: Text(
                router['routerName'] ?? '',
              ),
              subtitle: Text(
                'SSID: ${router['ssid'] ?? ''}\n'
                    'IP: ${router['ipAddress'] ?? ''}\n'
                    'Status: ${router['status'] ?? ''}',
              ),
            ),
          );
        },
      ),
    );
  }
}