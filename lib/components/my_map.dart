import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kavach/components/main_component.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide Theme;
import 'package:flutter_compass_v2/flutter_compass_v2.dart';

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
    _loadData();
    _initStyle();
    _getCurrentLocation().then((value) {
      initialLocation = value;
    });
    super.initState();
  }

  var isLoading = false;

  _loadData() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    final supabaseClient = Supabase.instance.client;
    if (widget.filters.isEmpty) {
      data = [];
      return;
    }
    debugPrint(widget.filters.map((e) => getTextFromTypeFilter(e)).toList()[0]);
    final supaData = await supabaseClient.from('incidents').select().filter(
          'incident_type',
          'in',
          widget.filters.map((e) => getTextFromTypeFilter(e)).toList(),
        );

    List<WeightedLatLng> tdata = [];
    for (var e in supaData) {
      tdata.add(
        WeightedLatLng(
          LatLng(e['latitude'] as double, e['longitude'] as double),
          1,
        ),
      );
    }
    data = tdata;
    isLoading = false;
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
    await Permission.locationWhenInUse.request(); // double check

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  final Map<double, MaterialColor> gradient = {
    0.25: Colors.blue,
    0.55: Colors.red,
    0.85: Colors.pink,
    1.0: Colors.purple
  };

  List<Marker> getMarkers() {}

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

    return !isLoading
        ? FutureBuilder<dynamic>(
            future: !isLoading ? _loadData() : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return LoadingAnimationWidget.beat(
                  color: Colors.black,
                  size: 40,
                );
              }
              return FlutterMap(
                mapController: _controller,
                options: MapOptions(
                    initialCenter: initialLocation,
                    initialZoom: 17.0,
                    maxZoom: 22,
                    backgroundColor: Theme.of(context).canvasColor),
                children: [
                  !isLoading
                      ? VectorTileLayer(
                          tileProviders: _style!.providers,
                          theme: _style!.theme,
                          sprites: _style!.sprites,
                          maximumZoom: 22,
                          tileOffset: TileOffset.mapbox,
                          layerMode: VectorTileLayerMode.vector,
                        )
                      : Container(),
                  StreamBuilder<CompassEvent>(
                      stream: FlutterCompass.events,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                              'Error reading heading: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const Text('Heading not available');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        double? direction = snapshot.data!.heading;

                        // if direction is null, then device does not support this sensor
                        // show error message
                        if (direction == null) {
                          return const Center(
                            child: Text("Device does not have sensors!!"),
                          );
                        }

                        if (_controller.camera.zoom > 20) {
                          return const SizedBox();
                        }
                        return CurrentLocationLayer();
                      }),
                  (_controller.camera.zoom > 20)
                      ? MarkerLayer(markers: getMarkers())
                      : Container(),

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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  data.isNotEmpty
                      ? HeatMapLayer(
                          heatMapDataSource:
                              InMemoryHeatMapDataSource(data: data),
                          heatMapOptions: HeatMapOptions(
                              gradient: gradient, minOpacity: 0.1),
                          // reset: _rebuildStream.stream,
                        )
                      : Container(),
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
            })
        : Container();
  }
}
