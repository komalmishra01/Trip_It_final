import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/keys.dart';

class WorldMapWidget extends StatelessWidget {
  final Function(String) handlePinTap;

  const WorldMapWidget({super.key, required this.handlePinTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(initialCenter: LatLng(20, 0), initialZoom: 2.0),
          children: [
            TileLayer(
              urlTemplate:
                  "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=${ApiKeys.geoapifyKey}",
              userAgentPackageName: 'com.tripit.app',
            ),

            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(-8.4095, 115.1889), // Bali, Indonesia
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Bali, Indonesia"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.orange,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(35.6762, 139.6503), // Tokyo, Japan
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Tokyo, Japan"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(51.5074, -0.1278), // London, UK
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("London, UK"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.blue,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(10.8505, 76.2711), // Kerala, India
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Kerala, India"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.green,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(25.3176, 82.9739), // Kashi (Varanasi), India
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Kashi, India"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.purple,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(26.9239, 75.8267), // Hawa Mahal, Jaipur
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Hawa Mahal, Jaipur"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.pink,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(36.3932, 25.4615), // Santorini, Greece
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Santorini, Greece"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),

                Marker(
                  point: LatLng(29.9792, 31.1342), // Giza Plateau, Egypt
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => handlePinTap("Giza Plateau, Egypt"),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.yellow,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
