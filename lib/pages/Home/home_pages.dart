import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:new_app/core/helper/api.dart';
import 'package:new_app/pages/Home/height_widget.dart';
import 'package:new_app/pages/Home/spo2.dart';
import 'package:new_app/pages/Home/weight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'age.dart';
import 'BMICalculator.dart.dart';
import 'heart_widget.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double height = 170.0;
  int weight = 70;
  String userName = "";
  int age = 0;
  int heartRate = 115; // Initial heart rate, will be updated dynamically
  String emotion = "Happy"; // Initial emotion, will be updated dynamically
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('currentUserName') ?? 'User';
    });
  }

  Future<void> _fetchData() async {
    final List<Map<String, dynamic>> requestData = [
      {"Heart Rate": heartRate, "Age": age}
    ];
    try {
      final responseData = await apiService.postEmotion(requestData);
      setState(() {
        emotion = responseData[0]['Emotion'];
      });

      if (emotion != "Happy" && emotion != "Normal") {
        await apiService.sendNotification(
            "The user's emotion is $emotion based on current heart rate and age.");
        log(emotion);
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $userName",
                  style: const TextStyle(color: Colors.black45, fontSize: 18),
                ),
                Text(
                  "Smart Mood",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800),
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Get Start",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 18),
                      ),
                    ),
                    const Image(
                      image: AssetImage(
                        'assets/images/sticker 1.png',
                      ),
                      height: 190,
                      width: 210,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Activity Status",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                HeartRateWidget(heartRate: heartRate, emotion: emotion),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: const Spo2()),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: BMICala(weight, height),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    HeightWidget(
                      onHeightChanged: (newHeight) {
                        setState(() {
                          height = newHeight;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: WeightWidget(
                        onWeightChanged: (newWeight) {
                          setState(() {
                            weight = newWeight;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: AgeWidget(
                            onAgeChanged: (newAge) {
                              setState(() {
                                age = newAge;
                                _fetchData(); // Fetch data whenever age changes
                              });
                            },
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
