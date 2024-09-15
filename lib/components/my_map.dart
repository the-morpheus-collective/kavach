import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kavach/components/main_component.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide Theme;

import 'package:kavach/secrets.dart' as s;

class MyMap extends StatefulWidget {
  final Set<TypeFilter> filters;
  final LocData? selectedLocation;

  const MyMap({super.key, this.selectedLocation, required this.filters});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final MapController _controller = MapController();
  Style? _style;

  List<WeightedLatLng> data = [];

  LatLng initialLocation = const LatLng(0.0, 0.0);

  @override
  void initState() {
    // _loadData();
    _initStyle();
    _getCurrentLocation().then((value) {
      initialLocation = value;
    });
    super.initState();
  }

  @override
  dispose() {
    // _rebuildStream.close();
    super.dispose();
  }

  Future<Style> _readStyle() {
    return StyleReader(
      uri: 'https://api.maptiler.com/maps/positron/style.json?key={key}',
      apiKey: s.maptilerApiKey,
      logger: const Logger.console(),
    ).read();
  }

  void _initStyle() async {
    try {
      _style = await _readStyle();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    if (_style == null) {
      return LoadingAnimationWidget.beat(
        color: Colors.black,
        size: 40,
      );
    }

    if (widget.selectedLocation != null) {
      _controller.move(
        LatLng(
          widget.selectedLocation!.lat,
          widget.selectedLocation!.lon,
        ),
        15.0,
      );
    }

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
          initialCenter: initialLocation,
          initialZoom: 15.0,
          maxZoom: 22,
          backgroundColor: Theme.of(context).canvasColor),
      children: [
        VectorTileLayer(
          tileProviders: _style!.providers,
          theme: _style!.theme,
          sprites: _style!.sprites,
          maximumZoom: 22,
          tileOffset: TileOffset.mapbox,
          layerMode: VectorTileLayerMode.vector,
        ),
        CurrentLocationLayer(),
        widget.selectedLocation != null
            ? MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      widget.selectedLocation?.lat ?? 0.0,
                      widget.selectedLocation?.lon ?? 0.0,
                    ),
                    width: 21,
                    height: 21,
                    child: Stack(
                      children: [
                        Container(
                          width: 21,
                          height: 21,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                spreadRadius: 0.0,
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        // HeatMapLayer(
        //   heatMapDataSource: InMemoryHeatMapDataSource(data: data),
        //   heatMapOptions: HeatMapOptions(gradient: gradient, minOpacity: 0.2),
        //   // reset: _rebuildStream.stream,
        // ),
        // RichAttributionWidget(
        //   // Include a stylish prebuilt attribution widget that meets all requirments
        //   attributions: [
        //     TextSourceAttribution(
        //       'OpenStreetMap contributors',
        //       onTap: () => {}, // (external)
        //     ),
        //     // Also add images...
        //   ],
        // ),
      ],
    );
  }
}
