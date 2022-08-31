import 'package:flutter/material.dart';

import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/time.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/widgets/daily_forecast.dart';

class SevenDayForecast extends StatefulWidget {
  const SevenDayForecast(
      {Key? key,
      required this.currentWeather,
      required this.weatherAQI,
      required this.forecastHourly})
      : super(key: key);
  final WeatherModel currentWeather;
  final WeatherAQI weatherAQI;
  final ForecastHourly forecastHourly;
  @override
  State<SevenDayForecast> createState() => _SevenDayForecastState();
}

class _SevenDayForecastState extends State<SevenDayForecast> {
  @override
  Widget build(BuildContext context) {
    return SevenDayTiles(
        currentWeather: widget.currentWeather,
        weatherAQI: widget.weatherAQI,
        forecastHourly: widget.forecastHourly);
  }
}

class SevenDayTiles extends StatelessWidget {
  const SevenDayTiles({
    Key? key,
    required this.currentWeather,
    required this.weatherAQI,
    required this.forecastHourly,
  }) : super(key: key);
  final WeatherModel currentWeather;
  final WeatherAQI weatherAQI;
  final ForecastHourly forecastHourly;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
              colors: [Color.fromARGB(255, 0, 68, 255), Colors.lightBlue])),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.height * 0.02,
              child: const Text(
                '5-day Forecast',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.02,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DailyForecast(
                    day: 'Today',
                    temp: '${currentWeather.main!.temp.round()}',
                    icon: currentWeather.weather![0].main,
                    date: getDateFromTimestamp(currentWeather.dt),
                  ),
                  DailyForecast(
                    day: 'Tomorrow',
                    temp: '${forecastHourly.hourly[7].main!.temp.round()}',
                    icon: forecastHourly.hourly[7].weather![0].main,
                    date: getDateFromTimestamp(forecastHourly.hourly[7].dt),
                  ),
                  DailyForecast(
                    day: getDayFromTimestamp(forecastHourly.hourly[14].dt),
                    temp: '${forecastHourly.hourly[14].main!.temp.round()}',
                    icon: forecastHourly.hourly[14].weather![0].main,
                    date: getDateFromTimestamp(forecastHourly.hourly[14].dt),
                  ),
                  DailyForecast(
                    day: getDayFromTimestamp(forecastHourly.hourly[21].dt),
                    temp: '${forecastHourly.hourly[21].main!.temp.round()}',
                    icon: forecastHourly.hourly[21].weather![0].main,
                    date: getDateFromTimestamp(forecastHourly.hourly[21].dt),
                  ),
                  DailyForecast(
                    day: getDayFromTimestamp(forecastHourly.hourly[28].dt),
                    temp: '${forecastHourly.hourly[28].main!.temp.round()}',
                    icon: forecastHourly.hourly[28].weather![0].main,
                    date: getDateFromTimestamp(forecastHourly.hourly[28].dt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
