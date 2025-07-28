import 'package:demo/project_trying/AppBarExample.dart';
import 'package:demo/project_trying/BottomNavExample.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Log_in.dart';


// Product model to match your Firebase structure
class Product {
  final String id;
  final String productId;
  final String productName;
  final String productModel;
  final String productDescription;
  final int productPrice;
  final int stockQuantity;
  final bool isActive;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productModel,
    required this.productDescription,
    required this.productPrice,
    required this.stockQuantity,
    required this.isActive,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      productModel: data['product_model'] ?? '',
      productDescription: data['product_description'] ?? '',
      productPrice: data['product_price'] ?? 0,
      stockQuantity: data['stock_quantity'] ?? 0,
      isActive: data['is_active'] ?? false,
      imageUrl: data['imageUrl'] ?? '', // Added imageUrl from Firebase
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class admin_product_card extends StatefulWidget {
  @override
  State<admin_product_card> createState() => _admin_product_cardState();
}

class _admin_product_cardState extends State<admin_product_card> {
  bool _isLoggingOut = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarExample(screenWidth: screenWidth, screenHeight: screenHeight, isLoggingOut: _isLoggingOut, onLogout: _logout),
      bottomNavigationBar: BottomNavExample(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product_details')
            .where('is_active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();

          if (products.isEmpty) {
            return Center(
              child: Text('No products available'),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: 900,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: products.map((product) {
                    return Column(
                      children: [
                        SportsProductCard(product: product),
                        SizedBox(height: 15),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SportsProductCard extends StatelessWidget {
  final Product product;

  const SportsProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(),
          SizedBox(width: 20,height: 10,),

          // Product Details
          Expanded(
            child: _buildProductDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 100,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: product.imageUrl.isNotEmpty
            ? Image.network(
          product.imageUrl,
          width: 100,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        )
            : _buildFallbackImage(),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8FBC8F), // Sage green
            Color(0xFF6B8E6B), // Darker green
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            product.productName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            product.productModel,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    // Calculate discount (example: 45% off)
    int originalPrice = (product.productPrice * 1.8).round(); // Assuming 45% off
    int discountPercentage = ((originalPrice - product.productPrice) * 100 / originalPrice).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stock status
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: product.stockQuantity > 0 ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.stockQuantity > 0 ? 'In Stock (${product.stockQuantity})' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 10,
                  color: product.stockQuantity > 0 ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 10,
              color: Colors.grey[600],
            ),
          ],
        ),
        SizedBox(height: 8),

        // Product title
        Text(
          '${product.productName} (${product.productModel}) | ${product.productDescription}',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF0066CC),
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),

        // Price section
        Row(
          children: [
            Text(
              '₹',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '${product.productPrice}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'M.R.P: ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '₹$originalPrice',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '($discountPercentage% off)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Delivery info
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 12, color: Colors.black),
            children: [
              TextSpan(text: 'FREE delivery '),
              TextSpan(
                text: 'Sun, 27 Jul',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),

        Text(
          'Service: Installation',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),

        // Product ID and timestamps
        Text(
          'Product ID: ${product.productId}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
        Text(
          'Added: ${_formatDate(product.createdAt)}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: 12),

        // Add to cart button
        ElevatedButton(
          onPressed: (){},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 1,
          ),
          child: Icon(Icons.delete_outline_outlined,
          color: Colors.red,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}