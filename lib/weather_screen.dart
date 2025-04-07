import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app1/secrets.dart';
import 'additional_info_item.dart';
import 'hourly_forecast_item.dart';



class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> _currentWeatherFuture;



  // for icon
  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain; // You can choose a better icon here
      default:
        return Icons.help_outline; // Fallback icon for unknown weather
    }
  }





  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'london';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      if (res.statusCode != 200) {
        throw 'Failed to load weather data: ${res.statusCode}';
      }

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'API error: ${data['message']}';
      }
      return data;
    } catch (e) {
      throw 'Error: $e';
    }

  }

  @override
  void initState() {
    super.initState();
    _currentWeatherFuture = getCurrentWeather();
  }

  void _refreshWeather() {
    setState(() {
      _currentWeatherFuture = getCurrentWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _currentWeatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;
          final list = data['list'];
          if (list == null || list.length < 6) {
            return const Center(
              child: Text('Insufficient data available for hourly forecasts.'),
            );
          }

          final currentTemp = data['list'][0]['main']['temp'];
          final currentCondition = data['list'][0]['weather'][0]['main'] ?? 'Unknown';
          final currentIcon = getWeatherIcon(currentCondition); // Use the helper function

          final currentPressure = list[0]['main']['pressure'];
          final currentWindSpeed = list[0]['wind']['speed'];
          final currentHumidity = list[0]['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentIcon, // Dynamically get the correct icon
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentCondition, // Display the correct weather condition
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),

                              const SizedBox(height: 16),
                              // Text(
                              //   currentSky,
                              //   style: const TextStyle(
                              //     fontSize: 20,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Weather forecast cards
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 7,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = list[index + 1];
                      final hourlySky = list[index + 1]['weather'][0]['main'];
                      final hourlyTemp =
                      hourlyForecast['main']['temp'].toString();
                      final time =
                      DateTime.parse(hourlyForecast['dt_txt']);

                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icons: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        value: hourlyTemp,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditonalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditonalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditonalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
