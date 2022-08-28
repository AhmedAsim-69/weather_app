// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/time.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/pages/seven_day_forecast.dart';
import 'package:weather_app/services/shared_preferences.dart';
import 'package:weather_app/services/weather_bloc.dart';
import 'package:weather_app/widgets/hourly_forecast.dart';
import 'package:weather_app/widgets/info_card.dart';
import 'package:weather_app/widgets/three_day_tile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // LocationData? currentLocation;
  // StreamSubscription<LocationData>? locationSubscription;
  Location locationService = Location();
  String error = '';
  String lat = '0';
  String lon = '0';
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  final _locationService = Location();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    lat = UserSimplePreferences.getLatitude() ?? '0';
    lon = UserSimplePreferences.getLongitude() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    log('123');
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        initPlatformState();

        _locationSubscription = _locationService.onLocationChanged
            .listen((LocationData currentLocation) async {
          setState(() async {
            _currentLocation = currentLocation;

            lat = _currentLocation!.latitude.toString();
            lon = _currentLocation!.longitude.toString();
            await UserSimplePreferences.storeLatitude(lat);
            await UserSimplePreferences.storeLongitude(lon);
          });
        });

        return FutureBuilder(
          future: getCurrentWeather(lat, lon),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              WeatherModel weather = snapshot.data[0];
              WeatherAQI weatherAQI = snapshot.data[1];
              ForecastHourly weatherHourly = snapshot.data[2];
              if (weather == null) {
              } else {
                return UserStack(
                    currentWeather: weather,
                    weatherAQI: weatherAQI,
                    forecastHourly: weatherHourly);
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
            return const Text('smthn went wrong');
          },
        );
      },
    );
  }

  void initPlatformState() async {
    LocationData? myLocation;
    try {
      myLocation = await locationService.getLocation();
      error = '';
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission Denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission Denied - Please ask the user to enable it from app settings';
      }
      myLocation = null;
    }
  }
}

class UserStack extends StatelessWidget {
  UserStack({
    Key? key,
    required this.currentWeather,
    required this.weatherAQI,
    required this.forecastHourly,
  }) : super(key: key);

  final ForecastHourly forecastHourly;
  final WeatherAQI weatherAQI;
  final WeatherModel currentWeather;
  String background = './images/bg_clear.png';
  late final bgWeather = currentWeather.weather![0].main;
  @override
  Widget build(BuildContext context) {
    if (bgWeather == 'Thunderstorm') {
      background = './images/bg_thunderstorm.png';
    } else if (bgWeather == 'Drizzle' || bgWeather == 'Rain') {
      background = './images/bg_rain.png';
    } else if (bgWeather == 'Clear' || bgWeather == 'Haze') {
      background = './images/bg_clear.png';
    } else if (bgWeather == 'Clouds') {
      background = './images/bg_cloudy.png';
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
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
                height: MediaQuery.of(context).size.height * 1.6,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.07,
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
                top: MediaQuery.of(context).size.height * 0.13,
                bottom: 0,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Search Cities",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.24,
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
                        child: Row(
                          children: [
                            const SizedBox(
                              height: 30,
                              width: 30,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: ImageIcon(
                                  AssetImage("images/leaf.png"),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            Text(
                              "  AQI ${weatherAQI.main![0].aqi}    ",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.62,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HourlyForecast(
                      time: 'Now',
                      temp: '${currentWeather.main!.temp.round()}',
                      icon: currentWeather.weather![0].main,
                      wind:
                          (currentWeather.wind!.speed * 3.6).toStringAsFixed(2),
                    ),
                    HourlyForecast(
                      time: getTimeFromTimestamp(forecastHourly.hourly[0].dt),
                      temp: '${forecastHourly.hourly[0].main!.temp.round()}',
                      icon: forecastHourly.hourly[0].weather![0].main,
                      wind: (forecastHourly.hourly[0].wind!.speed * 3.6)
                          .toStringAsFixed(2),
                    ),
                    HourlyForecast(
                      time: getTimeFromTimestamp(forecastHourly.hourly[1].dt),
                      temp: '${forecastHourly.hourly[1].main!.temp.round()}',
                      icon: forecastHourly.hourly[1].weather![0].main,
                      wind: (forecastHourly.hourly[1].wind!.speed * 3.6)
                          .toStringAsFixed(2),
                    ),
                    HourlyForecast(
                      time: getTimeFromTimestamp(forecastHourly.hourly[2].dt),
                      temp: '${forecastHourly.hourly[2].main!.temp.round()}',
                      icon: forecastHourly.hourly[2].weather![0].main,
                      wind: (forecastHourly.hourly[2].wind!.speed * 3.6)
                          .toStringAsFixed(2),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.8,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
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
                        icon: forecastHourly.hourly[0].weather![0].main,
                      ),
                      ThreeDayTile(
                        day: 'Tomorrow',
                        temp: '${forecastHourly.hourly[10].main!.temp.round()}',
                        weatherMain: forecastHourly.hourly[10].weather![0].main,
                        icon: forecastHourly.hourly[10].weather![0].main,
                      ),
                      ThreeDayTile(
                        day: getDayFromTimestamp(forecastHourly.hourly[15].dt),
                        temp: '${forecastHourly.hourly[15].main!.temp.round()}',
                        weatherMain: forecastHourly.hourly[15].weather![0].main,
                        icon: forecastHourly.hourly[15].weather![0].main,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 1.02,
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
                            '7-Day Forecast',
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
                top: MediaQuery.of(context).size.height * 1.11,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
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
                top: MediaQuery.of(context).size.height * 1.47,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: const [
                      InfoCard(
                          label1: 'Air Quality Index',
                          label2: '',
                          text1: "17",
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
