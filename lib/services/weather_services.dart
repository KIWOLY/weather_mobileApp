import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/weather_model.dart';

class WeatherServices {
  final String apikey;

  WeatherServices(this.apikey);

  /// Fetch weather for a specific city
  Future<Weather> getWeather(String cityName) async {
    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': cityName,
        'appid': apikey,
        'units': 'metric',
      },
    );

    final response = await http.get(uri);

    print('Request URL: $uri');
    print('Response code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch weather');
    }
  }

  /// Get the user's current city using GPS
  Future<String> getCurrentCity() async {
    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Dar es Salaam'; // fallback city
    }

    // Use LocationSettings instead of deprecated desiredAccuracy
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // optional, updates only if moved 10 meters
    );

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    // Convert coordinates into a Placemark
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // Extract city name
    String? city = placemarks[0].locality;
    return city ?? 'Dar es Salaam';
  }

  /// Fetch weather for the user's current location
  Future<Weather> getWeatherForCurrentLocation() async {
    String city = await getCurrentCity();
    return await getWeather(city);
  }
}
