import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String day;
  final String description;
  final double temperature;

  const WeatherCard({
    super.key,
    required this.day,
    required this.description,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(day),
        subtitle: Text(description),
        trailing: Text('${temperature.toStringAsFixed(1)}°C'),
      ),
    );
  }
}
