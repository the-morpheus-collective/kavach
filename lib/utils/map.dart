import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:kavach/secrets.dart';

Future<LatLng> getCurrentLocation() async {
  final position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}

Future<LatLng> getNearestPoliceStation(LatLng currentCoords) async {
  Response res = await get(
    Uri.parse(
        "https://eu1.locationiq.com/v1/nearby?key=$locationIqToken&tag=amenity:police&radius=5000&format=json&lat=${currentCoords.latitude}&lon=${currentCoords.longitude}"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to get nearest police station");
  }

  final List<dynamic> data = jsonDecode(res.body);
  if (data.isEmpty) {
    throw Exception("No police station found");
  }

  final Map<String, dynamic> first = data.first;

  double lat = double.parse(first['lat']);
  double lon = double.parse(first['lon']);

  return LatLng(lat, lon);
}

Uri getRouteURLToCoordinates(LatLng currentCoords, LatLng policeCoords) {
  return Uri.parse(
      "https://www.google.com/maps/dir/?api=1&origin=${currentCoords.latitude},${currentCoords.longitude}&destination=${policeCoords.latitude},${policeCoords.longitude}&travelmode=car");
}

Future<LatLng> getNearestHospital(LatLng currentCoords) async {
  Response res = await get(
    Uri.parse(
        "https://eu1.locationiq.com/v1/nearby?key=$locationIqToken&tag=hospital&radius=5000&format=json&lat=${currentCoords.latitude}&lon=${currentCoords.longitude}"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to get nearest hospital");
  }

  final List<dynamic> data = jsonDecode(res.body);
  if (data.isEmpty) {
    throw Exception("No hospital found");
  }

  final Map<String, dynamic> first = data.first;

  double lat = double.parse(first['lat']);
  double lon = double.parse(first['lon']);

  return LatLng(lat, lon);
}
