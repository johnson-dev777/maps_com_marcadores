
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/mapa_controller.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  late final MapaController controller;

  @override
  void initState() {
    super.initState();

    controller = MapaController();
    controller.carregarDados();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFPI - Mapa de Localização'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: controller.atualizarMapa,
                initialCameraPosition: CameraPosition(
                  target: controller.centroInicial,
                  zoom: 14,
                ),
                markers: controller.marcadores,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomControlsEnabled: true,
              ),

              if (controller.carregando)
                const Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (controller.erro != null)
                Positioned(
                  bottom: 90,
                  left: 12,
                  right: 12,
                  child: Card(
                    color: Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        controller.erro!,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                bottom: 20,
                right: 16,
                child: FloatingActionButton(
                  onPressed: controller.carregando
                      ? null
                      : controller.obterLocalizacao,
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
