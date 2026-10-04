import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router_service.dart';

class EditRouterScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> router;

  const EditRouterScreen({
    super.key,
    required this.router,
  });

  @override
  ConsumerState<EditRouterScreen> createState() =>
      _EditRouterScreenState();
}

class _EditRouterScreenState extends ConsumerState<EditRouterScreen> {
  late final TextEditingController routerNameController;
  late final TextEditingController ssidController;
  late final TextEditingController macController;
  late final TextEditingController ipController;
  late final TextEditingController locationController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    routerNameController = TextEditingController(
      text: widget.router['routerName'] ?? '',
    );

    ssidController = TextEditingController(
      text: widget.router['ssid'] ?? '',
    );

    macController = TextEditingController(
      text: widget.router['macAddress'] ?? '',
    );

    ipController = TextEditingController(
      text: widget.router['ipAddress'] ?? '',
    );

    locationController = TextEditingController(
      text: widget.router['location'] ?? '',
    );

    latitudeController = TextEditingController(
      text: widget.router['latitude']?.toString() ?? '',
    );

    longitudeController = TextEditingController(
      text: widget.router['longitude']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    routerNameController.dispose();
    ssidController.dispose();
    macController.dispose();
    ipController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
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
      r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$',
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

    final latitude = double.tryParse(
      latitudeController.text.trim(),
    );

    final longitude = double.tryParse(
      longitudeController.text.trim(),
    );

    if (latitude == null || latitude < -90 || latitude > 90) {
      return 'Enter a valid Latitude (-90 to 90)';
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      return 'Enter a valid Longitude (-180 to 180)';
    }

    return null;
  }

  Future<void> updateRouter() async {
    final validationError = validateForm();

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ref.read(routerServiceProvider).updateRouter(
        id: widget.router['id'],
        routerName: routerNameController.text.trim(),
        ssid: ssidController.text.trim(),
        macAddress: macController.text.trim(),
        ipAddress: ipController.text.trim(),
        location: locationController.text.trim(),
        latitude: double.parse(
          latitudeController.text.trim(),
        ),
        longitude: double.parse(
          longitudeController.text.trim(),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final message =
        ref.read(routerServiceProvider).getErrorMessage(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Router'),
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

            const SizedBox(height: 16),

            TextField(
              controller: latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Example: 28.6139',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Example: 77.2090',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : updateRouter,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Update Router'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}