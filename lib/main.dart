import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'qoobeey',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qoobey chips&chicken'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/vv.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodBuyingScreen()),
                  );
                },
                child: Text('JOIN US'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodBuyingScreen extends StatefulWidget {
  @override
  _FoodBuyingScreenState createState() => _FoodBuyingScreenState();
}

class _FoodBuyingScreenState extends State<FoodBuyingScreen> {
  List<FoodItem> foodItems = [
    FoodItem('baasto', 'images/baasto.jpg', 2, 0),
    FoodItem('bariis', 'images/baris.jpg', 2, 0),
    FoodItem('humbeger', 'images/hum.jpg', 3, 0),
    FoodItem('malay', 'images/malay.jpg', 5, 0),
    FoodItem('macaroni', 'images/ss.jpg', 2, 0),
    FoodItem('canjero', 'images/ca.jpg', 2, 0),
    FoodItem('malawax', 'images/ma.jpg', 2, 0),
    FoodItem('suugo', 'images/sugo.jpg', 1, 0),
    FoodItem('malay', 'images/maly.jpg', 5, 0),
    FoodItem('reddrink', 'images/red.jpg', 2, 0),
    FoodItem('bluedrink', 'images/ble.png', 2, 0),
    FoodItem('orange', 'images/orange.jpg', 2, 0),
    FoodItem('dark', 'images/dark.jpg', 2, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DOORO CUNTO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return FoodItemTile(
                  foodItem: foodItems[index],
                  onQuantityChanged: (quantity) {
                    setState(() {
                      foodItems[index].quantity = quantity;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                final controller = PrimaryScrollController.of(context);
                controller.animateTo(
                  controller.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(Icons.arrow_downward),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<FoodItem> selectedItems = foodItems.where((item) => item.quantity > 0).toList();
          if (selectedItems.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationScreen(foodItems: selectedItems),
              ),
            );
          } else {
            // Show an alert informing the user to select at least one item
            // ...
          }
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

class FoodItemTile extends StatelessWidget {
  final FoodItem foodItem;
  final ValueChanged<int> onQuantityChanged;

  FoodItemTile({required this.foodItem, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(foodItem.title),
      subtitle: Text('\$${foodItem.price}'),
      leading: Image.asset(
        foodItem.image,
        width: 50,
        height: 50,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              if (foodItem.quantity > 0) {
                onQuantityChanged(foodItem.quantity - 1);
              }
            },
          ),
          Text(foodItem.quantity.toString()),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              onQuantityChanged(foodItem.quantity + 1);
            },
          ),
        ],
      ),
    );
  }
}

class FoodItem {
  final String title;
  final String image;
  final double price;
  int quantity;

  FoodItem(this.title, this.image, this.price, this.quantity);
}

class RegistrationScreen extends StatelessWidget {
  final List<FoodItem> foodItems;

  RegistrationScreen({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegistrationForm(foodItems: foodItems),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final List<FoodItem> foodItems;

  RegistrationForm({required this.foodItems});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> _registerUser() async {
    final selectedItems = widget.foodItems.where((item) => item.quantity > 0).toList();

    final registrationData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'selectedItems': selectedItems.map((item) => {'title': item.title, 'quantity': item.quantity}).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/register'),
        body: jsonEncode(registrationData),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Registration successful');

        String restaurantName = 'Qoobey';
        double totalPrice = selectedItems.map((item) => item.price * item.quantity).reduce((a, b) => a + b);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: ${_fullNameController.text}'),
                  Text('Email: ${_emailController.text}'),
                  Text('Phone: ${_phoneController.text}'),
                  Text('Selected Food: ${selectedItems.map((item) => item.title).join(', ')}'),
                  Text('Restaurant: $restaurantName'),
                  Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StarRatingScreen()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _registerUser();
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRatingScreen extends StatefulWidget {
  @override
  _StarRatingScreenState createState() => _StarRatingScreenState();
}

class _StarRatingScreenState extends State<StarRatingScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please rate your experience:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                  ),
                  color: index < _rating ? Colors.amber : Colors.grey,
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_rating > 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Thank You!'),
                        content: Text('You rated $_rating stars. Thanks for your feedback!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Rating Required'),
                        content: Text('Please select a rating before submitting.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    text: 'Location: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: 'Somali in Mogadishu\n',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: 'Phone: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: '+2526183338388',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
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
