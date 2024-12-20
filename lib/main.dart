import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Météo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class WeatherModel {
  final String cityName;
  final DateTime date;
  final String description;
  final String icon;
  final double temperature;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.date,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: json['main']['temp'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
    );
  }
}

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _currentWeather;
  String _errorMessage = '';
  bool _isLoading = false;

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01':
        return WeatherIcons.day_sunny;
      case '02':
        return WeatherIcons.day_cloudy;
      case '03':
        return WeatherIcons.cloud;
      case '04':
        return WeatherIcons.cloudy;
      case '09':
        return WeatherIcons.rain;
      case '10':
        return WeatherIcons.day_rain;
      case '11':
        return WeatherIcons.thunderstorm;
      case '13':
        return WeatherIcons.snow;
      case '50':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.day_sunny;
    }
  }

  void _fetchWeather() async {
    if (_cityController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather =
          await _weatherService.fetchCurrentWeather(_cityController.text);
      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ville non trouvée ou erreur réseau';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[300]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher une ville',
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                            ),
                            onSubmitted: (_) => _fetchWeather(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _fetchWeather,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_currentWeather != null)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _currentWeather!.cityName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              DateFormat('EEEE d MMMM', 'fr_FR')
                                  .format(_currentWeather!.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 32),
                            Icon(
                              _getWeatherIcon(_currentWeather!.icon),
                              size: 80,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_currentWeather!.temperature.round()}°C',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Text(
                              _currentWeather!.description,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherDetail(
                                  WeatherIcons.humidity,
                                  '${_currentWeather!.humidity}%',
                                  'Humidité',
                                ),
                                _buildWeatherDetail(
                                  WeatherIcons.strong_wind,
                                  '${_currentWeather!.windSpeed} m/s',
                                  'Vent',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_errorMessage.isNotEmpty)
                  Card(
                    color: Colors.red[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(_errorMessage,
                              style: TextStyle(color: Colors.red[900])),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue[700]),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
