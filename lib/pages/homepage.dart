// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/shared_preferences.dart';
import 'package:weather_app/services/weather_bloc.dart';
import 'package:weather_app/widgets/user_stack.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String? city;

class _MyHomePageState extends State<MyHomePage> {
  Location locationService = Location();
  final _locationService = Location();
  String error = '';
  String lat = '0';
  String lon = '0';
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    lat = UserSimplePreferences.getLatitude() ?? '0';
    lon = UserSimplePreferences.getLongitude() ?? '0';
    city = UserSimplePreferences.getCity();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        initPlatformState();

        locationSubscription = _locationService.onLocationChanged
            .listen((LocationData currentLocation) async {
          setState(() async {
            _currentLocation = currentLocation;

            lat = _currentLocation!.latitude.toString();
            lon = _currentLocation!.longitude.toString();
            await UserSimplePreferences.storeLatitude(lat);
            await UserSimplePreferences.storeLongitude(lon);
            if (city != null) {
              await UserSimplePreferences.storeCity(city!);
            }
          });
        });

        return FutureBuilder(
          future: getCurrentWeather(lat, lon, city),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              WeatherModel weather = snapshot.data[0];
              WeatherAQI weatherAQI = snapshot.data[1];
              ForecastHourly weatherHourly = snapshot.data[2];

              if (snapshot.hasError) {
                return Text('${snapshot.data}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return UserStack(
                      currentWeather: weather,
                      weatherAQI: weatherAQI,
                      forecastHourly: weatherHourly);
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const Text("Working to get data");
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

  void initPlatformState() async {
    try {
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
