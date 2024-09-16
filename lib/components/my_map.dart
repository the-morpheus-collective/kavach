import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  final showMarker;

  const MyMap(
      {super.key,
      this.selectedLocation,
      required this.filters,
      required this.showMarker});

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

    // onZoomChanged.listen((event) {
    //   print('New zoom is $event');

    //   selfZoomState = event;
    // });
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
      markerData = [];
      return;
    }
    debugPrint(widget.filters.map((e) => getTextFromTypeFilter(e)).toList()[0]);
    final supaData = await supabaseClient.from('incidents').select().filter(
          'incident_type',
          'in',
          widget.filters.map((e) => getTextFromTypeFilter(e)).toList(),
        );

    List<WeightedLatLng> tdata = [];
    List<Marker> tmarkerData = [];
    for (var e in supaData) {
      try {
        tdata.add(
          WeightedLatLng(
            LatLng(e['latitude'] as double, e['longitude'] as double),
            1,
          ),
        );
      } catch (_) {}
      try {
        tmarkerData.add(
          Marker(
            point: LatLng(e['latitude'] as double, e['longitude'] as double),
            width: 21,
            height: 21,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  popUpTitle = "${e['incident_type'] as String} Incident";
                  final DateFormat formatter = DateFormat('dd-MM-yy');
                  final DateTime createdTime = DateTime.parse(e['timestamp']);
                  if (e['description'] == null) {
                    popUpDescription =
                        "No description available\nCreated at: ${formatter.format(createdTime)}";
                  } else {
                    popUpDescription = e['description'] as String;
                    popUpDescription +=
                        "\nCreated at: ${formatter.format(createdTime)}";
                  }
                });
              },
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
                        color: getColor(getTypeFilter(e["incident_type"])),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (_) {}
    }
    data = tdata;
    markerData = tmarkerData;
    isLoading = false;
  }

  // final _streamController = StreamController<double>();
  // Stream<double> get onZoomChanged => _streamController.stream;

  @override
  dispose() {
    // _rebuildStream.close();
    // _streamController.close();
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

  List<Marker> markerData = [];

  // var selfZoomState = 17.0;

  var popUpTitle = "";
  var popUpDescription = "";

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
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                        initialCenter: initialLocation,
                        initialZoom: 19.0,
                        maxZoom: 22,
                        backgroundColor: Theme.of(context).canvasColor,
                        onPositionChanged: (position, hasGesture) {}),
                    children: [
                      // !isLoading
                      VectorTileLayer(
                        tileProviders: _style!.providers,
                        theme: _style!.theme,
                        sprites: _style!.sprites,
                        maximumZoom: 22,
                        tileOffset: TileOffset.mapbox,
                        layerMode: VectorTileLayerMode.vector,
                      ),
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
                            return CurrentLocationLayer();
                          }),
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
                                          borderRadius:
                                              BorderRadius.circular(100),
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
                      data.isNotEmpty && !isLoading && !widget.showMarker
                          ? HeatMapLayer(
                              heatMapDataSource:
                                  InMemoryHeatMapDataSource(data: data),
                              heatMapOptions: HeatMapOptions(
                                  gradient: gradient, minOpacity: 0.1),
                              // reset: _rebuildStream.stream,
                            )
                          : Container(),
                      widget.showMarker
                          ? MarkerLayer(markers: markerData)
                          : Container()

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
                  ),
                  popUpTitle.isNotEmpty && popUpDescription.isNotEmpty
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 0.0, 0.0, 110.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFFFFFFFF,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  left: BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 2.0),
                                    child: Text(
                                      popUpTitle,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: Text(
                                      popUpDescription,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFF000000),
                                        enableFeedback: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 6, 8, 6),
                                        minimumSize: const Size(0, 0),
                                      ),
                                      onPressed: () => showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          iconColor: Colors.white,
                                          backgroundColor: Colors.black,
                                          title: const Text(
                                            'Stay Safe!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          content: Text(
                                            getSafetyContent(popUpTitle),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.white,
                                                enableFeedback: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    16.0,
                                                  ),
                                                ),
                                                minimumSize: const Size(0, 0),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: const Text("Tips to Stay Safe"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
            })
        : Container();
  }
}
