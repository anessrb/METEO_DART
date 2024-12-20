import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _currentWeather;
  String _errorMessage = '';

  void _fetchWeather() async {
    setState(() {
      _errorMessage = '';
    });
    try {
      final weather =
          await _weatherService.fetchCurrentWeather(_cityController.text);
      setState(() {
        _currentWeather = weather;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ville non trouvée ou erreur réseau';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Entrez une ville',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Obtenir la météo'),
            ),
            const SizedBox(height: 16),
            if (_currentWeather != null) _buildWeatherInfo(_currentWeather!),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ville : ${weather.cityName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Date : ${DateFormat('dd/MM/yyyy').format(weather.date)}'),
        Text('Description : ${weather.description}'),
        Text('Température : ${weather.temperature}°C'),
        Text('Humidité : ${weather.humidity}%'),
        Text('Vent : ${weather.windSpeed} m/s'),
      ],
    );
  }
}
