import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  List<dynamic> prices = [];
  Map<String, dynamic> purchasedProducts = {};

  @override
  void initState() {
    super.initState();
    // Call the function to fetch initial data
    fetchData();
    fetchDynamicData();
    // Call the function periodically every 10 seconds
    Timer.periodic(const Duration(seconds: 3), (Timer t) => fetchDynamicData());
  }

  Future<void> fetchData() async {
    var response = await http.get(Uri.parse('http://192.168.1.12:8000/products'));
    if(response.statusCode == 200) {
      products = jsonDecode(response.body);
    }
    response = await http.get(Uri.parse('http://192.168.1.12:8000/prices'));
    if(response.statusCode == 200) {
      prices = jsonDecode(response.body);
    }
  }

  Future<void> fetchDynamicData() async {
    print('Fetch Data');
    final response = await http.get(Uri.parse('http://192.168.1.12:8000/purchased-products'));
    if (response.statusCode == 200) {
      setState(() {
        purchasedProducts = jsonDecode(response.body);
        print(purchasedProducts);
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: purchasedProducts.length,
        itemBuilder: (BuildContext context, int index) {
          int productWeight = purchasedProducts[index.toString()];
          return ListTile(
            title: Text(products[index]),
            subtitle: Text(productWeight.toString()),
          );
        },
      ),
    );
  }
}
