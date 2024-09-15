import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide Theme;

import 'package:kavach/secrets.dart' as s;

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final MapController _controller = MapController();
  Style? _style;

  List<WeightedLatLng> data = [];

  @override
  void initState() {
    // _loadData();
    _initStyle();
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

  @override
  Widget build(BuildContext context) {
    if (_style == null) {
      return LoadingAnimationWidget.beat(
        color: Colors.black,
        size: 40,
      );
    }

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
          initialCenter: const LatLng(
            30.76894444,
            76.57519444,
          ),
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
