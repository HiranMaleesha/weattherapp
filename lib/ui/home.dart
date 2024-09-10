import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_wether_check/models/constants.dart';
import 'package:mobile_wether_check/widgets/weather_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants myConstants = Constants();

  // initialization
  int temperature = 0;
  int maxTemp = 0;
  String weatherStateName = 'Loading..';
  int humidity = 0;
  int windSpeed = 0;

  var currentDate = 'Loading..';
  String imageUrl = '';
  String apiKey = '4dbca896378d4704bfb155052240909'; // API key
  String location = 'London'; // Our default city

  List consolidatedWeatherList = []; // To hold weather data after API call

  // API calls URL
  String searchWeatherUrl =
      'https://api.openweathermap.org/data/2.5/weather?q='; // Weather details using the city name

  // Get weather data for a specific location
  void fetchWeatherData(String location) async {
    var weatherResult = await http.get(
      Uri.parse('$searchWeatherUrl$location&appid=$apiKey&units=metric'),
    );

    if (weatherResult.statusCode == 200) {
      var result = json.decode(weatherResult.body);

      setState(() {
        // Ensure 'main' and 'weather' exist in the response
        if (result['main'] != null && result['weather'] != null) {
          temperature = result['main']['temp']?.round() ?? 0;
          maxTemp = result['main']['temp_max']?.round() ?? 0;
          humidity = result['main']['humidity']?.round() ?? 0;
          windSpeed = result['wind']['speed']?.round() ?? 0;
          weatherStateName = result['weather'][0]['main'] ?? 'Unknown';
        }

        // Date formatting
        var myDate =
            DateTime.now(); // OpenWeather doesn't provide the date directly
        currentDate = DateFormat('EEEE, d MMMM').format(myDate);

        // Set the image URL based on weather state
        imageUrl = weatherStateName.replaceAll(' ', '').toLowerCase();
      });
    } else {
      print('Failed to fetch weather data: ${weatherResult.statusCode}');
      // Handle the error, set default values
      setState(() {
        weatherStateName = 'Error';
        temperature = 0;
        maxTemp = 0;
        humidity = 0;
        windSpeed = 0;
        currentDate = 'Error';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(location);
  }

  // Create a shader linear gradient
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: const Color.fromARGB(255, 94, 174, 240),
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/images/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pin.png',
                    width: 20,
                  ),
                  const SizedBox(width: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: location,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['London', 'New York', 'Tokyo', 'Paris']
                            .map((String location) {
                          return DropdownMenuItem(
                              value: location, child: Text(location));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            location = newValue!;
                            fetchWeatherData(location);
                          });
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/get-started.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            Text(
              currentDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 50),
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: myConstants.primaryColor.withOpacity(.5),
                      offset: const Offset(0, 25),
                      blurRadius: 10,
                      spreadRadius: -12,
                    )
                  ]),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    child: Image.asset(
                      'assets/images/showers.png', // Adjust for weather image
                      width: 150,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      weatherStateName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 192, 87, 87),
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            temperature.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          ),
                        ),
                        Text(
                          '°C',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weatherItem(
                    text: 'Wind Speed',
                    value: windSpeed,
                    unit: 'km/h',
                    imageUrl: 'assets/images/windspeed.png',
                  ),
                  weatherItem(
                      text: 'Humidity',
                      value: humidity,
                      unit: '%',
                      imageUrl: 'assets/images/humidity.png'),
                  weatherItem(
                    text: 'Max Temp',
                    value: maxTemp,
                    unit: '°C',
                    imageUrl: 'assets/images/max-temp.png',
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
