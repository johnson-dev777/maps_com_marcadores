
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalModel {
  final String id;
  final String nome;
  final String endereco;
  final LatLng coordenadas;

  const LocalModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.coordenadas,
  });
}
