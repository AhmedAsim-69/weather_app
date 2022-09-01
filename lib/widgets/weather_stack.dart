// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/utils/assets.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/pages/homepage.dart';
import 'package:weather_app/pages/seven_day_forecast.dart';
import 'package:weather_app/services/cities_service.dart';
import 'package:weather_app/services/user_simple_preferences.dart';
import 'package:weather_app/services/weather_bloc.dart';
import 'package:weather_app/widgets/hourly_forecast.dart';
import 'package:weather_app/widgets/info_card.dart';
import 'package:weather_app/widgets/three_day_tile.dart';

class WeatherStack extends StatelessWidget {
  WeatherStack({
    Key? key,
    required this.currentWeather,
    required this.weatherAQI,
    required this.forecastHourly,
    required this.city,
  }) : super(key: key);

  String city;
  final ForecastHourly forecastHourly;
  final WeatherAQI weatherAQI;
  final WeatherModel currentWeather;
  late final _bgWeather = (currentWeather.weather![0].main == 'Clear')
      ? Assets.clear
      : (currentWeather.weather![0].main == 'Clouds' ||
              currentWeather.weather![0].main == 'Smoke')
          ? Assets.clouds
          : (currentWeather.weather![0].main == 'Drizzle')
              ? Assets.drizzle
              : (currentWeather.weather![0].main == 'Rain')
                  ? Assets.rain
                  : (currentWeather.weather![0].main == 'Thunderstorm')
                      ? Assets.thunderStorm
                      : Assets.clear;
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      _height = MediaQuery.of(context).size.width;
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_bgWeather),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: _height * 1.6,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                top: _height * 0.07,
                child: Text(
                  "${currentWeather.name}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              Positioned(
                top: _height * 0.15,
                bottom: 0,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      SizedBox(
                        child: Form(
                          key: _formKey,
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              controller: _typeAheadController,
                              decoration: InputDecoration(
                                errorStyle: const TextStyle(fontSize: 12),
                                hintText: "Search Cities",
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 5.0),
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                    }
                                  },
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please select a city';
                              }
                              return null;
                            },
                            suggestionsCallback: (pattern) {
                              return CitiesService.getSuggestions(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.toString()),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (suggestion) {
                              _typeAheadController.text = suggestion.toString();
                            },
                            onSaved: (value) async {
                              city = _typeAheadController.text;
                              if (city != 'null') {
                                await UserSimplePreferences.storeCity(city);
                              }
                              Navigator.pushAndRemoveUntil<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (context) => BlocProvider(
                                    create: (context) => WeatherBloc(),
                                    child:
                                        const MyHomePage(title: 'Weather App'),
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _height * 0.22,
                child: Column(
                  children: [
                    SizedBox(
                      height: _height * 0.24,
                      child: Text(
                        "${currentWeather.main?.temp.round()}\u2103",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 120,
                        ),
                      ),
                    ),
                    Text(
                      currentWeather.weather![0].main,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: ImageIcon(
                                    AssetImage(Assets.leaf),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Text(
                                "  AQI ${weatherAQI.main![0].aqi}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: _height * 0.62,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.96,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HourlyForecast(
                        time: 'Now',
                        temp: '${currentWeather.main!.temp.round()}',
                        icon: currentWeather.weather![0].icon,
                        wind: (currentWeather.wind!.speed * 3.6)
                            .toStringAsFixed(2),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      HourlyForecast(
                        time: Constants.getTimeFromTimestamp(
                          forecastHourly.hourly[0].dt,
                        ),
                        temp: '${forecastHourly.hourly[0].main!.temp.round()}',
                        icon: forecastHourly.hourly[0].weather![0].icon,
                        wind: (forecastHourly.hourly[0].wind!.speed * 3.6)
                            .toStringAsFixed(2),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      HourlyForecast(
                        time: Constants.getTimeFromTimestamp(
                          forecastHourly.hourly[1].dt,
                        ),
                        temp: '${forecastHourly.hourly[1].main!.temp.round()}',
                        icon: forecastHourly.hourly[1].weather![0].icon,
                        wind: (forecastHourly.hourly[1].wind!.speed * 3.6)
                            .toStringAsFixed(2),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      HourlyForecast(
                        time: Constants.getTimeFromTimestamp(
                          forecastHourly.hourly[2].dt,
                        ),
                        temp: '${forecastHourly.hourly[2].main!.temp.round()}',
                        icon: forecastHourly.hourly[2].weather![0].icon,
                        wind: (forecastHourly.hourly[2].wind!.speed * 3.6)
                            .toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _height * 0.8,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ThreeDayTile(
                        day: 'Today',
                        temp: '${forecastHourly.hourly[0].main!.temp.round()}',
                        weatherMain: forecastHourly.hourly[0].weather![0].main,
                        icon: forecastHourly.hourly[0].weather![0].icon,
                      ),
                      ThreeDayTile(
                        day: 'Tomorrow',
                        temp: '${forecastHourly.hourly[10].main!.temp.round()}',
                        weatherMain: forecastHourly.hourly[10].weather![0].main,
                        icon: forecastHourly.hourly[10].weather![0].icon,
                      ),
                      ThreeDayTile(
                        day: Constants.getDayFromTimestamp(
                            forecastHourly.hourly[15].dt),
                        temp: '${forecastHourly.hourly[15].main!.temp.round()}',
                        weatherMain: forecastHourly.hourly[15].weather![0].main,
                        icon: forecastHourly.hourly[15].weather![0].icon,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _height * 1.02,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(98, 255, 255, 255),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          child: const Text(
                            '5-Day Forecast',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SevenDayForecast(
                                    currentWeather: currentWeather,
                                    weatherAQI: weatherAQI,
                                    forecastHourly: forecastHourly),
                              ),
                            );
                          },
                        ),
                      )),
                ),
              ),
              Positioned(
                top: _height * 1.11,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      InfoCard(
                          label1: 'Real feel',
                          label2: 'Humidity',
                          text1: "${currentWeather.main!.feels_like.round()}",
                          text2: "${currentWeather.main!.humidity}%"),
                      InfoCard(
                          label1: 'Chances of rain',
                          label2: 'Pressure',
                          text1: "55%",
                          text2:
                              "${(currentWeather.main!.pressure / 1013.25).round()}atm"),
                      InfoCard(
                          label1: 'Wind speed',
                          label2: 'UV index',
                          text1:
                              "${(currentWeather.wind!.speed * 3.6).toStringAsFixed(2)} km/h",
                          text2: "7"),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _height * 1.47,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      InfoCard(
                          label1: 'Air Quality Index',
                          label2: '',
                          text1: "${weatherAQI.main![0].aqi}",
                          text2: "Full air quality forecast",
                          textSize2: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
