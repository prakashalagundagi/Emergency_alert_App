import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  final Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Future<LocationData?> getCurrentLocation() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          return null;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      final locationData = await _location.getLocation();
      return locationData;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<bool> isLocationEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  Future<PermissionStatus> checkLocationPermission() async {
    try {
      return await _location.hasPermission();
    } catch (e) {
      print('Error checking location permission: $e');
      return PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> requestLocationPermission() async {
    try {
      return await _location.requestPermission();
    } catch (e) {
      print('Error requesting location permission: $e');
      return PermissionStatus.denied;
    }
  }

  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }
}
