import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Log_in.dart';

class admin_add extends StatefulWidget {
  const admin_add({super.key});

  @override
  State<admin_add> createState() => _admin_addState();
}

class _admin_addState extends State<admin_add> {
  final _productName = TextEditingController();
  final _productPrice = TextEditingController();
  final _productModel = TextEditingController();
  final _productDescription = TextEditingController();
  final _stockQuantity = TextEditingController();
  final _productID = TextEditingController();
  final _imageUrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingOut = false;
  bool _isAddingProduct = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add product to Firebase
  Future<bool> addProduct({
    required String productName,
    required String productId,
    required String productPrice,
    required String productModel,
    required String productDescription,
    required String stockQuantity,
    required String imageUrl,
  }) async {
    try {
      // Convert string values to appropriate types
      double price = double.parse(productPrice);
      int quantity = int.parse(stockQuantity);

      // Create product data map
      Map<String, dynamic> productData = {
        'product_name': productName,
        'product_id': productId,
        'product_price': price,
        'product_model': productModel,
        'product_description': productDescription,
        'stock_quantity': quantity,
        'imageUrl':imageUrl,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };

      // Use product_id as document ID
      await _firestore.collection('product_details').doc(productId).set(productData);

      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Function to check if product ID already exists
  Future<bool> isProductIdExists(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('product_details').doc(productId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking product ID: $e');
      return false;
    }
  }

  // Function to add product
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isAddingProduct = true;
    });

    try {
      // Check if product ID already exists
      bool productExists = await isProductIdExists(_productID.text);

      if (productExists) {
        _showErrorMessage('Product ID already exists!');
        setState(() {
          _isAddingProduct = false;
        });
        return;
      }

      // Add product to Firebase
      bool success = await addProduct(
        productName: _productName.text,
        productId: _productID.text,
        productPrice: _productPrice.text,
        productModel: _productModel.text,
        productDescription: _productDescription.text,
        stockQuantity: _stockQuantity.text,
        imageUrl:_imageUrl.text,
      );

      if (success) {
        _showSuccessMessage('Product added successfully!');
        _clearForm();
      } else {
        _showErrorMessage('Failed to add product. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isAddingProduct = false;
      });
    }
  }

  // Helper function to show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Helper function to show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Helper function to clear form
  void _clearForm() {
    _productName.clear();
    _productPrice.clear();
    _productModel.clear();
    _productDescription.clear();
    _stockQuantity.clear();
    _productID.clear();
    _imageUrl.clear();
  }

  // Validation functions
  String? validateProductPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product price';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid product price';
    }

    return null;
  }

  String? validateStockQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product stock quantity';
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Please enter a valid stock quantity';
    }

    return null;
  }

  // Simple logout function
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Navigate to login page immediately after signout
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Log_in()),
                (route) => false,
          );
        }
      } catch (e) {
        // Handle logout error
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  int MyIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.05;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            toolbarHeight: 70,
            title: Row(
              children: [
                // Logo and title section
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network("https://res.cloudinary.com/debdioyvy/image/upload/v1753083433/Final_Logo_qqkgm2.jpg",
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ATHLETIX",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout button
                ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  icon: _isLoggingOut
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.logout, size: 16),
                  label: Text(_isLoggingOut ? "Logging out..." : "Logout"),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF1F346B),
                margin: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'Add product',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Product Name TextFormField
                            TextFormField(
                              controller: _productName,
                              decoration: InputDecoration(
                                hintText: "Enter product name:",
                                prefixIcon: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product name';
                                }
                                final nameRegex = RegExp(r'^[A-Za-z\s]{3,29}$');
                                if (!nameRegex.hasMatch(value)) {
                                  return 'Please enter a valid product name (3-29 characters)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Product ID TextFormField
                            TextFormField(
                              controller: _productID,
                              decoration: InputDecoration(
                                hintText: "Enter product ID:",
                                prefixIcon: Icon(Icons.tag, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product ID';
                                }
                                final idRegex = RegExp(r"^[A-Za-z0-9]{3,20}$");
                                if (!idRegex.hasMatch(value)) {
                                  return 'Please enter a valid product ID (3-20 characters)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Product Price TextFormField
                            TextFormField(
                              controller: _productPrice,
                              decoration: InputDecoration(
                                hintText: "Enter product price:",
                                prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.number,
                              validator: validateProductPrice,
                            ),
                            const SizedBox(height: 20),

                            // Product Model TextFormField
                            TextFormField(
                              controller: _productModel,
                              decoration: InputDecoration(
                                hintText: "Enter product model:",
                                prefixIcon: Icon(Icons.model_training, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product model';
                                }
                                final modelRegex = RegExp(r'^[A-Za-z0-9\s-]{3,39}$');
                                if (!modelRegex.hasMatch(value)) {
                                  return 'Please enter a valid product model (3-39 characters)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Product Description TextFormField
                            TextFormField(
                              controller: _productDescription,
                              decoration: InputDecoration(
                                hintText: "Enter product description:",
                                prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product description';
                                }
                                if (value.length < 10 || value.length > 500) {
                                  return 'Description must be between 10-500 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Stock Quantity TextFormField
                            TextFormField(
                              controller: _stockQuantity,
                              decoration: InputDecoration(
                                hintText: "Enter product stock quantity:",
                                prefixIcon: Icon(Icons.inventory, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.number,
                              validator: validateStockQuantity,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _imageUrl,
                              decoration: InputDecoration(
                                hintText: "Enter image URL:",
                                prefixIcon: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter image URL';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20,),

                            // ADD Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01,
                                  horizontal: screenWidth * 0.01,
                                ),
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.30,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 3,
                              ),
                              onPressed: _isAddingProduct ? null : _addProduct,
                              child: _isAddingProduct
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Adding...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              )
                                  : Text(
                                'ADD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}