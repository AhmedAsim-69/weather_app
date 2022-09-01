import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';

class WeatherData {
  final WeatherModel weatherModel;
  final WeatherAQI weatherAQI;
  final ForecastHourly forecastHourly;

  WeatherData(this.weatherModel, this.weatherAQI, this.forecastHourly);
}

class WeatherService {
  static Future<WeatherData> getCurrentWeather(
      [String? lat, String? lon, String? city]) async {
    WeatherModel weather = WeatherModel();
    WeatherAQI weatherAQI = WeatherAQI();
    ForecastHourly weatherHourly = ForecastHourly(hourly: []);
    String api = 'f85916ee555786a3c8cdd4ee9d1b19f1';
    http.Response response = (city == null || city == 'null')
        ? await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$api&units=metric'))
        : await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$api&units=metric'));
    http.Response responseAQI = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$api&units=metric'));
    http.Response responseHourly = (city == null || city == 'null')
        ? await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$api&units=metric'))
        : await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$api&units=metric'));
    if (response.statusCode == 200 &&
        responseAQI.statusCode == 200 &&
        responseHourly.statusCode == 200) {
      weather = WeatherModel.fromJson(jsonDecode(response.body));
      weatherAQI = WeatherAQI.fromJson(jsonDecode(responseAQI.body));
      weatherHourly = ForecastHourly.fromJson(jsonDecode(responseHourly.body));
    } else {
      log('something went wronggggg');
    }
    return WeatherData(weather, weatherAQI, weatherHourly);
  }
}
