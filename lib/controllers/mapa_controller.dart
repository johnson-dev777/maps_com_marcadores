
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/local_model.dart';

class MapaController extends ChangeNotifier {
  Set<Marker> marcadores = {};

  bool carregando = false;
  String? erro;

  LatLng? minhaLocalizacao;

  GoogleMapController? mapController;

  final LatLng centroInicial = const LatLng(
    -5.0955,
    -42.8125,
  );

  final List<LocalModel> locais = const [
    LocalModel(
      id: 'IFPI-CENTRO',
      nome: 'IFPI - Campus Teresina Central',
      endereco: 'Praça da Liberdade, 1597 - Centro, Teresina - PI',
      coordenadas: LatLng(-5.0888219, -42.8112273),
    ),
    LocalModel(
      id: 'IFPI-CENTRO-SUL',
      nome: 'IFPI - Campus Teresina Zona Sul',
      endereco: 'Av. Pedro Freitas, 1020 - São Pedro, Teresina - PI',
      coordenadas: LatLng(-5.10225453, -42.81401045),
    ),
  ];

  Future<void> carregarDados() async {
    _carregarMarcadores();
    await obterLocalizacao();
  }

  void _carregarMarcadores() {
    marcadores = locais.map((local) {
      return Marker(
        markerId: MarkerId(local.id),
        position: local.coordenadas,
        infoWindow: InfoWindow(
          title: local.nome,
          snippet: local.endereco,
        ),
      );
    }).toSet();

    notifyListeners();
  }

  void atualizarMapa(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> obterLocalizacao() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        throw Exception(
          'Ative o serviço de localização do dispositivo.',
        );
      }

      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão de localização não concedida.',
        );
      }

      final Position posicao =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      minhaLocalizacao = LatLng(
        posicao.latitude,
        posicao.longitude,
      );

      marcadores.removeWhere(
        (marker) =>
            marker.markerId.value == 'MINHA-LOCALIZACAO',
      );

      marcadores.add(
        Marker(
          markerId: const MarkerId('MINHA-LOCALIZACAO'),
          position: minhaLocalizacao!,
          infoWindow: const InfoWindow(
            title: 'Minha localização atual',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          minhaLocalizacao!,
          15,
        ),
      );
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Erro ao obter localização: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
