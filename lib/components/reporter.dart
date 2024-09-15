import 'package:flutter/material.dart';
import 'package:kavach/components/main_component.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> report(TypeFilter type, LatLng currentPosition) async {
  // add a quick report to db
  final supabaseClient = Supabase.instance.client;

  try {
    await supabaseClient.from('incidents').insert({
      'incident_type': getTextFromTypeFilter(type),
      'description': 'Quick Report',
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
      'genuinity': 4,
      'status': 'active'
    });
    return true;
  } catch (e) {
    return false;
  }
}
