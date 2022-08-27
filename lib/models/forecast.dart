import 'package:weather_app/models/weather.dart';

class Hourly {
  final int? dt;
  final Main? main;

  final double? temp;
  final double? feelsLike;
  final double? pressure;
  final List<Weather>? weather;
  final Clouds? clouds;
  final Wind? wind;

  final double? visibility;
  final String? description;
  final String? icon;

  Hourly(
      {this.dt,
      this.main,
      this.temp,
      this.clouds,
      this.wind,
      this.feelsLike,
      this.pressure,
      this.weather,
      this.visibility,
      this.description,
      this.icon});

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      dt: json['dt'].toInt(),
      main: Main.fromJson(json['main']),
      weather: (json['weather'] as List)
          .map((item) => Weather.fromJson(item))
          .toList(),
      clouds: Clouds.fromJson(json['clouds']),
      wind: Wind.fromJson(json['wind']),
      temp: json['main']['temp'].toDouble(),
      pressure: json['main']['pressure'].toDouble(),
      visibility: json['visibility'].toDouble(),
    );
  }
}

class ForecastHourly {
  final List<Hourly> hourly;

  ForecastHourly({
    required this.hourly,
  });

  factory ForecastHourly.fromJson(Map<String, dynamic> json) {
    List<dynamic> hourlyData = json['list'];

    List<Hourly> hourly = <Hourly>[];

    for (var item in hourlyData) {
      var hour = Hourly.fromJson(item);
      hourly.add(hour);
    }

    return ForecastHourly(
      hourly: hourly,
    );
  }
}
