import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  List<dynamic> prices = [];
  Map<String, dynamic> purchasedProducts = {};
  List<String> purchasedProductsIndexes = [];
  double totalPrice = 0.0;
  String upiId = '';
  // ignore: non_constant_identifier_names
  static String RPI_IP = '192.168.1.2';
  String URL = 'http://$RPI_IP:8000';
  final textEditingController = TextEditingController();

  Future<void> fetchData(String url) async {
    var response = await http.get(Uri.parse('$url/data'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      products = data['products'];
      prices = data['prices'];
      upiId = data['upi_id'];
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchDynamicData(String url) async {
    final response = await http.get(Uri.parse('$url/purchased-products'));
    if (response.statusCode == 200) {
      setState(() {
        purchasedProducts = jsonDecode(response.body);
        purchasedProductsIndexes = purchasedProducts.keys.toList();
        totalPrice = 0.0;
        for (var i in purchasedProductsIndexes) {
          totalPrice += prices[int.parse(i)] * purchasedProducts[i] / 1000;
        }
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    textEditingController.text = RPI_IP;
    fetchData(URL).then((value) {
      super.initState();
    });
    Timer.periodic(
      const Duration(seconds: 3),
      (Timer t) => fetchDynamicData(URL),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Text(
              'Shopping Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontFamily: 'RobotoSlab',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          toolbarHeight: 80.0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          actions: [
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              clipBehavior: Clip.hardEdge,
              enableFeedback: false,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("Set RPi IP"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        content: SizedBox(
                          height: 150,
                          width: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey[600]),
                                  hintText: "IP Address of Raspberry PI",
                                  fillColor: Colors.white70,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    URL =
                                        'http://${textEditingController.text}:8000';
                                    fetchData(URL);
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Text(
                                  'Set IP',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: purchasedProducts.length,
              itemBuilder: (BuildContext context, int index) {
                int productIdx = int.parse(purchasedProductsIndexes[index]);
                int productWeightGrams =
                    purchasedProducts[purchasedProductsIndexes[index]];
                String productWeight = productWeightGrams < 1000
                    ? '$productWeightGrams g'
                    : '${productWeightGrams / 1000} Kg';
                double productPrice =
                    productWeightGrams * prices[productIdx] / 1000;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  child: ListTile(
                    title: Text(
                      products[productIdx],
                      style: const TextStyle(
                        color: Color(0xf0000000),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      productWeight,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                    ),
                    tileColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    leading:
                        Image.asset('assets/product-icons/placeholder.png'),
                    trailing: Text(
                      '\u{20B9}${productPrice.toString()}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 75,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Total Price: \u{20B9}${totalPrice.toString()}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton(
                    onPressed: () async {
                      String upiurl =
                          'upi://pay?pa=$upiId&pn=Owner&tn=Groceries&am=$totalPrice&cu=INR';
                      await launchUrl(Uri.parse(upiurl));
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      side: const BorderSide(
                        color: Colors.black26,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                    ),
                    child: const Text('Pay Now'),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
