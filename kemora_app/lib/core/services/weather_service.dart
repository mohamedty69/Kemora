import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  /// Fetches the current temperature and weather description for given coordinates
  /// using the free Open-Meteo API.
  Future<Map<String, String>> getCurrentWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        if (current != null) {
          final temp = current['temperature'];
          final weatherCode = current['weathercode'];
          final description = _getWeatherDescription(weatherCode);
          return {
            'temperature': '${temp.round()}°C',
            'weather': description,
          };
        }
      }
    } catch (e) {
      // Return defaults on error
    }
    return {
      'temperature': '--°C',
      'weather': 'Unknown',
    };
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1:
      case 2:
      case 3: return 'Mainly clear, partly cloudy, and overcast';
      case 45:
      case 48: return 'Fog and depositing rime fog';
      case 51:
      case 53:
      case 55: return 'Drizzle: Light, moderate, and dense intensity';
      case 56:
      case 57: return 'Freezing Drizzle: Light and dense intensity';
      case 61:
      case 63:
      case 65: return 'Rain: Slight, moderate and heavy intensity';
      case 66:
      case 67: return 'Freezing Rain: Light and heavy intensity';
      case 71:
      case 73:
      case 75: return 'Snow fall: Slight, moderate, and heavy intensity';
      case 77: return 'Snow grains';
      case 80:
      case 81:
      case 82: return 'Rain showers: Slight, moderate, and violent';
      case 85:
      case 86: return 'Snow showers slight and heavy';
      case 95: return 'Thunderstorm: Slight or moderate';
      case 96:
      case 99: return 'Thunderstorm with slight and heavy hail';
      default: return 'Unknown';
    }
  }
}
