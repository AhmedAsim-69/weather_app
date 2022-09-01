import 'package:flutter/material.dart';
import 'package:weather_app/utils/assets.dart';

class HourlyForecast extends StatelessWidget {
  const HourlyForecast({
    Key? key,
    required this.icon,
    required this.time,
    required this.wind,
    required this.temp,
  }) : super(key: key);

  final String icon;
  final String time;
  final String wind;
  final String temp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Wrap(
          children: [
            Text(
              "$temp\u2103",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
        Image.asset(
          'assets/images/$icon.png',
          height: 22,
          width: 32,
        ),
        Row(
          children: [
            Image.asset(
              Assets.wind,
              height: 15,
              width: 15,
            ),
            Text(
              '$wind km/h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        )
      ],
    );
  }
}
