import 'package:flutter/material.dart';

class DailyForecast extends StatelessWidget {
  const DailyForecast({
    Key? key,
    required this.icon,
    required this.day,
    required this.date,
    required this.temp,
  }) : super(key: key);

  final String icon;
  final String day;
  final String date;
  final String temp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        Text(
          ' $date ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/$icon.png',
            height: 50,
            width: 50,
          ),
        ),
        Text(
          "$temp\u2103",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
