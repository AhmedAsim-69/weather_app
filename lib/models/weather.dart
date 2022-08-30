// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/forecast.dart';

class Coord {
  final double lon;
  final double lat;

  Coord({required this.lon, required this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
        lon: double.parse(json['lon'].toString()),
        lat: double.parse(json['lat'].toString()));
  }
}

class AQIList {
  final int aqi;

  AQIList({
    required this.aqi,
  });

  factory AQIList.fromJson(Map<String, dynamic> json) {
    return AQIList(
      aqi: json["main"]["aqi"],
    );
  }
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather(
      {required this.id,
      required this.main,
      required this.description,
      required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        id: json['id'],
        main: json['main'],
        description: json['description'],
        icon: json['icon']);
  }
}

class Main {
  final double temp;
  final double pressure;
  final int humidity;
  final double feels_like;

  final double temp_min;
  final double temp_max;
  final double sea_level;
  final double grnd_level;

  Main(
      {required this.temp,
      required this.pressure,
      required this.humidity,
      required this.feels_like,
      required this.temp_min,
      required this.temp_max,
      required this.sea_level,
      required this.grnd_level});

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
        temp: double.parse(json['temp'].toString()),
        feels_like: double.parse(json['feels_like'].toString()),
        temp_min: double.parse(json['temp_min'].toString()),
        temp_max: double.parse(json['temp_max'].toString()),
        sea_level: json['sea_level'] == null
            ? 0.0
            : double.parse(json['sea_level'].toString()),
        grnd_level: json['grnd_level'] == null
            ? 0.0
            : double.parse(json['grnd_level'].toString()),
        pressure: double.parse(json['pressure'].toString()),
        humidity: json['humidity']);
  }
}

class Wind {
  final double speed;
  final double deg;

  Wind({required this.speed, required this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
        speed: double.parse(json['speed'].toString()),
        deg: double.parse(json['deg'].toString()));
  }
}

class Clouds {
  final int all;

  Clouds({required this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(all: json['all']);
  }
}

class Sys {
  final int sunrise;
  final int sunset;

  Sys({required this.sunrise, required this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(sunset: json['sunset'], sunrise: json['sunrise']);
  }
}

class WeatherModel {
  final Coord? coord;
  final List<Weather>? weather;
  final String? base;
  final Main? main;
  final int? visibility;
  final Wind? wind;
  final Clouds? clouds;
  final int? dt;
  final Sys? sys;
  final int? id;
  final String? name;
  final int? cod;

  WeatherModel(
      {this.coord,
      this.weather,
      this.base,
      this.main,
      this.visibility,
      this.wind,
      this.clouds,
      this.dt,
      this.sys,
      this.id,
      this.name,
      this.cod});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
        coord: Coord.fromJson(json['coord']),
        weather: (json['weather'] as List)
            .map((item) => Weather.fromJson(item))
            .toList(),
        base: json['base'],
        main: Main.fromJson(json['main']),
        visibility: json['visibility'],
        wind: Wind.fromJson(json['wind']),
        clouds: Clouds.fromJson(json['clouds']),
        dt: json['dt'],
        sys: Sys.fromJson(json['sys']),
        id: json['id'],
        name: json['name'],
        cod: json['cod']);
  }
}

class WeatherAQI {
  final Coord? coord;
  final List<AQIList>? main;

  WeatherAQI({
    this.coord,
    this.main,
  });

  factory WeatherAQI.fromJson(Map<String, dynamic> json) {
    return WeatherAQI(
      coord: Coord.fromJson(json['coord']),
      main:
          (json['list'] as List).map((item) => AQIList.fromJson(item)).toList(),
    );
  }
}

Future<List> getCurrentWeather([String? lat, String? lon, String? city]) async {
  WeatherModel weather = WeatherModel();
  WeatherAQI weatherAQI = WeatherAQI();
  ForecastHourly weatherHourly = ForecastHourly(hourly: []);
  String API = 'f85916ee555786a3c8cdd4ee9d1b19f1';

  http.Response response = (city == null || city == 'null')
      ? await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$API&units=metric'))
      : await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$API&units=metric'));
  http.Response responseAQI = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$API&units=metric'));
  http.Response responseHourly = (city == null || city == 'null')
      ? await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$API&units=metric'))
      : await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$API&units=metric'));
  if (response.statusCode == 200 &&
      responseAQI.statusCode == 200 &&
      responseHourly.statusCode == 200) {
    weather = WeatherModel.fromJson(jsonDecode(response.body));
    weatherAQI = WeatherAQI.fromJson(jsonDecode(responseAQI.body));
    weatherHourly = ForecastHourly.fromJson(jsonDecode(responseHourly.body));
  } else {
    log('something went wronggggg');
  }
  return [weather, weatherAQI, weatherHourly];
}
