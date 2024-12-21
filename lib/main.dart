import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Anglais
        Locale('fr', ''), // Français
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? currentWeather;
  Map<String, dynamic>? forecast;
  String? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getWeatherAndForecast('Montpellier'); // Ville par défaut
  }

  Future<void> _getWeatherAndForecast(String city) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Récupérer la météo actuelle
      final currentResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=d9010bb92a50d8ccf7cdee3d0f5fe843&units=metric&lang=fr'));

      // Récupérer la prévision sur 5 jours
      final forecastResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=d9010bb92a50d8ccf7cdee3d0f5fe843&units=metric&lang=fr'));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        setState(() {
          currentWeather = json.decode(currentResponse.body);
          forecast = json.decode(forecastResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Ville non trouvée';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur de connexion';
        isLoading = false;
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
            colors: [Colors.blue[300]!, Colors.blue[700]!],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : error != null
                  ? Center(
                      child: Text(error!,
                          style: const TextStyle(color: Colors.white)),
                    )
                  : currentWeather != null
                      ? Column(
                          children: [
                            _buildSearchBar(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildCurrentWeather(),
                                    _buildHourlyForecast(),
                                    _buildDailyForecast(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez une ville',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => _getWeatherAndForecast(value),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _getWeatherAndForecast(_cityController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            currentWeather!['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            _getWeatherIcon(currentWeather!['weather'][0]['icon']),
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            '${currentWeather!['main']['temp'].round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w200,
              height: 1, // Réglage pour centrer verticalement
            ),
          ),
          Text(
            currentWeather!['weather'][0]['description'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final hourlyData = forecast!['list'].take(6).toList();

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRÉVISIONS HORAIRES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hourData = hourlyData[index];
                final time =
                    DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);
                final hour = DateFormat('HH:mm').format(time);

                return Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Text(
                        hour,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Icon(
                        _getWeatherIcon(hourData['weather'][0]['icon']),
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        '${hourData['main']['temp'].round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    final dailyForecasts = <String, dynamic>{};
    for (var item in forecast!['list']) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyForecasts.containsKey(dayKey)) {
        dailyForecasts[dayKey] = {
          'temp_min': item['main']['temp_min'],
          'temp_max': item['main']['temp_max'],
          'icon': item['weather'][0]['icon'],
          'date': date,
        };
      } else {
        if (item['main']['temp_min'] < dailyForecasts[dayKey]['temp_min']) {
          dailyForecasts[dayKey]['temp_min'] = item['main']['temp_min'];
        }
        if (item['main']['temp_max'] > dailyForecasts[dayKey]['temp_max']) {
          dailyForecasts[dayKey]['temp_max'] = item['main']['temp_max'];
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRÉVISIONS 5 JOURS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...dailyForecasts.entries.take(5).map((entry) {
            final data = entry.value;
            final date = data['date'] as DateTime;
            final dayName =
                DateFormat('EEEE', 'fr_FR').format(date).capitalize();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      dayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(
                    _getWeatherIcon(data['icon']),
                    color: Colors.white,
                    size: 30,
                  ),
                  Text(
                    '${data['temp_min'].round()}° - ${data['temp_max'].round()}°',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

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
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
