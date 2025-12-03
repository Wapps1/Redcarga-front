import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/auth/domain/models/session/app_session.dart';
import 'package:red_carga/features/tracking/data/tracking_ws_service.dart';
import 'package:red_carga/features/tracking/domain/driver_location.dart';
import 'package:red_carga/features/tracking/presentation/blocs/driver_tracking_bloc.dart';

class DriverMapPage extends StatelessWidget {
  final int quoteId;
  const DriverMapPage({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSession?>(
      future: SessionStore().getAppSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data!;
        final wsService = TrackingWsService(
          wsUrl: 'wss://redcargabk-b4b7cng3ftb2bfea.canadacentral-01.azurewebsites.net/_dev/ws-tester-tracking.html', // TODO: mover a config
          session: session,
        );

        return BlocProvider(
          create: (_) => DriverTrackingBloc(
            wsService: wsService,
            quoteId: quoteId,
          )..add(const DriverTrackingStarted()),
          child: const _DriverMapView(),
        );
      },
    );
  }
}

class _DriverMapView extends StatefulWidget {
  const _DriverMapView();

  @override
  State<_DriverMapView> createState() => _DriverMapViewState();
}

class _DriverMapViewState extends State<_DriverMapView> {
  GoogleMapController? _mapController;
  LatLng _initialLatLng = const LatLng(-12.046374, -77.042793);

  @override
  void initState() {
    super.initState();
    debugPrint('[DriverMap] initState');
    _initCurrentPosition();
  }

  Future<void> _initCurrentPosition() async {
    debugPrint('[DriverMap] Iniciando _initCurrentPosition');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[DriverMap] serviceEnabled: $serviceEnabled');
    if (!serviceEnabled) {
      debugPrint('[DriverMap] Servicios de ubicación apagados');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[DriverMap] permiso inicial: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[DriverMap] permiso tras request: $permission');
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('[DriverMap] permisos denegados, abortando _initCurrentPosition');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      debugPrint('[DriverMap] posición obtenida: lat=${position.latitude}, lng=${position.longitude}');
      _initialLatLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_initialLatLng, 15));
      setState(() {});
    } catch (e) {
      debugPrint('[DriverMap] error obteniendo posición: $e');
    }
  }

  void _moveCamera(DriverLocation location) {
    debugPrint('[DriverMap] moveCamera -> ${location.lat}, ${location.lng}');
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(location.lat, location.lng),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DriverMap] build ejecutado con initialLatLng=$_initialLatLng');
    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: const [
                  Text(
                    'Mapa en tiempo real',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BlocConsumer<DriverTrackingBloc, DriverTrackingState>(
                  listener: (context, state) {
                    final loc = state.lastLocation;
                    if (loc != null) _moveCamera(loc);
                  },
                  builder: (context, state) {
                    final marker = state.lastLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('driver'),
                              position: LatLng(state.lastLocation!.lat, state.lastLocation!.lng),
                              infoWindow: InfoWindow(
                                title: 'Conductor',
                                snippet:
                                    'Vel: ${(state.lastLocation!.speed ?? 0).toStringAsFixed(1)} km/h',
                              ),
                            ),
                          }
                        : <Marker>{};

                    debugPrint('[DriverMap] markers count: ${marker.length}');
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialLatLng,
                        zoom: 13,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      markers: marker,
                      onMapCreated: (controller) {
                        debugPrint('[DriverMap] GoogleMap creado');
                        _mapController = controller;
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('[DriverMap] dispose');
    _mapController?.dispose();
    super.dispose();
  }
}