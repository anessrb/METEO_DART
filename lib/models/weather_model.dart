class WeatherModel {
  final String cityName;
  final DateTime date;
  final String description;
  final double temperature;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.date,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
    );
  }
}
