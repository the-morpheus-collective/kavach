import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kavach/components/main_component.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> report(TypeFilter type, LatLng currentPosition) async {
  // add a quick report to db
  final supabaseClient = Supabase.instance.client;
  const _storage = const FlutterSecureStorage();
  final userId = await _storage.read(key: 'user_id');
  if (userId == null) {
    return false;
  }
  var response =
      await supabaseClient.from('users').select().eq('phone_number', userId);

  try {
    await supabaseClient.from('incidents').insert({
      'user_id': response[0]['user_id'] as String,
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
