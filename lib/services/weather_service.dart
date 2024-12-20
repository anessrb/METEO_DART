import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = 'd9010bb92a50d8ccf7cdee3d0f5fe843';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> fetchCurrentWeather(String cityName) async {
    final url = Uri.parse(
        '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=fr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherModel.fromJson(json);
    } else {
      throw Exception('Erreur lors du chargement des données météo');
    }
  }
}
