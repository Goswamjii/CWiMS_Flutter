import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router_service.dart';
class AddRouterScreen extends ConsumerStatefulWidget {
  const AddRouterScreen({super.key});

  @override
  ConsumerState<AddRouterScreen> createState() => _AddRouterScreenState();
}

class _AddRouterScreenState extends ConsumerState<AddRouterScreen> {  final routerNameController = TextEditingController();
  final ssidController = TextEditingController();
  final macController = TextEditingController();
  final ipController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void dispose() {
    routerNameController.dispose();
    ssidController.dispose();
    macController.dispose();
    ipController.dispose();
    locationController.dispose();
    super.dispose();
  }


  String? validateForm() {
    if (routerNameController.text.trim().isEmpty) {
      return 'Router Name is required';
    }

    if (ssidController.text.trim().isEmpty) {
      return 'Wi-Fi Name (SSID) is required';
    }

    final mac = macController.text.trim();

    final macRegex = RegExp(
      r'^(([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}|'
      r'[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4})$',
    );

    if (!macRegex.hasMatch(mac)) {
      return 'Enter a valid MAC Address';
    }

    final ip = ipController.text.trim();

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (!ipRegex.hasMatch(ip)) {
      return 'Enter a valid IP Address';
    }

    if (locationController.text.trim().isEmpty) {
      return 'Location is required';
    }

    return null;
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Router'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: routerNameController,
              decoration: const InputDecoration(
                labelText: 'Router Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: ssidController,
              decoration: const InputDecoration(
                labelText: 'Wi-Fi Name (SSID)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: macController,
              decoration: const InputDecoration(
                labelText: 'MAC Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async { final validationError = validateForm();

                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validationError),
                    ),
                  );
                  return;
                }
                  try {
                    await ref.read(routerServiceProvider).createRouter(
                      routerName: routerNameController.text.trim(),
                      ssid: ssidController.text.trim(),
                      macAddress: macController.text.trim(),
                      ipAddress: ipController.text.trim(),
                      location: locationController.text.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final message =
                      ref.read(routerServiceProvider).getErrorMessage(e);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Add Router'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}