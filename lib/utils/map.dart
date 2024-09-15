import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng> getCurrentLocation() async {
  final position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}

Future<LatLng> getNearestPoliceStation(LatLng currentCoords) async {
  http.Response res = await http.get(
    Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$currentCoords&limit=5&format=json"),
  );
  return const LatLng(30.76856, 76.575366);
}

Uri getRouteURLToCoordinates(LatLng currentCoords) {
  return Uri();
}
