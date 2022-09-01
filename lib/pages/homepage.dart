// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/user_simple_preferences.dart';
import 'package:weather_app/services/weather_bloc.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/weather_stack.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locationService = Location();
  String error = '';
  String _lat = '0';
  String _lon = '0';
  String _city = 'null';
  bool _firstOpen = false;

  LocationData? _currentLocation;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _lat = UserSimplePreferences.getLatitude() ?? '0';
    _lon = UserSimplePreferences.getLongitude() ?? '0';
    _city = UserSimplePreferences.getCity() ?? 'null';
    if ((_lat == '0' && _lon == '0') && _city == 'null') {
      _firstOpen = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        _updateLocation();
        return FutureBuilder<WeatherData>(
          future: WeatherService.getCurrentWeather(_lat, _lon, _city),
          builder: (BuildContext context, AsyncSnapshot<WeatherData> snapshot) {
            if (snapshot.hasData) {
              WeatherModel weather = snapshot.data!.weatherModel;
              WeatherAQI weatherAQI = snapshot.data!.weatherAQI;
              ForecastHourly weatherHourly = snapshot.data!.forecastHourly;

              if (snapshot.hasError) {
                return Text('${snapshot.data}');
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return RefreshIndicator(
                    child: WeatherStack(
                      currentWeather: weather,
                      weatherAQI: weatherAQI,
                      forecastHourly: weatherHourly,
                      city: _city,
                    ),
                    onRefresh: () async {
                      _city = 'null';
                      await UserSimplePreferences.storeCity(_city);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => WeatherBloc(),
                            child: const MyHomePage(title: 'Weather App'),
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );

                      return _updateLocation();
                    },
                  );
                }
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

  Future<void> _updateLocation() async {
    _initPlatformState();

    locationSubscription = _locationService.onLocationChanged
        .listen((LocationData currentLocation) async {
      _currentLocation = currentLocation;

      _lat = _currentLocation!.latitude.toString();
      _lon = _currentLocation!.longitude.toString();
      await UserSimplePreferences.storeLatitude(_lat);
      await UserSimplePreferences.storeLongitude(_lon);
      if (_city != 'null') {
        await UserSimplePreferences.storeCity(_city);
      }
    });
  }

  Future<void> _initPlatformState() async {
    try {
      await _locationService.getLocation();
      _updateLocation();
      if (_firstOpen == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => WeatherBloc(),
              child: const MyHomePage(title: 'Weather App'),
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
      error = '';
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission Denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission Denied - Please ask the user to enable it from app settings';
      }
    }
  }
}
