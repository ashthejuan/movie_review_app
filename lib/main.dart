import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MovieReviewApp());
}

class MovieReviewApp extends StatelessWidget {
  const MovieReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Review App',
      theme: ThemeData(
        primaryColor: Color(0xFF171738),
        scaffoldBackgroundColor: Color(0xFFC9CAD9),

        colorScheme: ColorScheme.light(
          primary: Color(0xFF171738),
          onPrimary: Colors.white,
        ),
        textTheme: TextTheme(
          titleLarge:TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF171738)),
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF171738)),
          bodySmall: TextStyle(fontSize: 14, color: Color(0xFF171738)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF171738),
            foregroundColor: Colors.white,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF171738)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF171738)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF171738)),
          ),
        ),
      ),
      home: MovieReviewScreen(),
    );
  }
}

class MovieReviewScreen extends StatefulWidget {
  const MovieReviewScreen({super.key});

  @override
  _MovieReviewScreenState createState() => _MovieReviewScreenState();
}

class _MovieReviewScreenState extends State<MovieReviewScreen> {
  List<Map<String, String>> reviews = [];
  bool _isLoading = false;
  String? _errorMessage;


  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  late SharedPreferences _prefs;

  @override
  void initState(){
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _movieNameController.dispose();
    _genreController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async{
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try{
      _prefs = await SharedPreferences.getInstance();
        final savedReviews = _prefs.getStringList('reviews');
        if (savedReviews!= null){
          setState(() {
            reviews = savedReviews.map((json) {
              try{
                return Map<String, String>.from(jsonDecode(json));
              } catch(e) {
                print("Error decoding review: $e");
                return <String, String>{};
              }
            }).where((map)=>map.isNotEmpty).toList();
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Failed to load reviews: $e";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    
  Future<void> _saveReviews() async {
    try {
      await _prefs.setStringList(
          'reviews', reviews.map((review) => jsonEncode(review)).toList());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save review: $e')),
      );
    }
  }

  String? _validateInputs() {
    if (_movieNameController.text.trim().isEmpty) {
      return 'Movie name cannot be empty';
    }
    if (_genreController.text.trim().isEmpty) {
      return 'Genre cannot be empty';
    }
    if (_reviewController.text.trim().isEmpty) {
      return 'Review cannot be empty';
    }
    if (_reviewController.text.trim().length > 180) {
      return 'Review must be less than 180 characters';
    }
    return null;
  }

  void _addReview(){
    final validationError = _validateInputs();
    if (validationError != null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    try{
      setState(() {
        reviews.add({
          'movieName': _movieNameController.text.trim(),
          'genre': _genreController.text.trim(),
          'review': _reviewController.text.trim(),
        });
      });

      _saveReviews();

      _movieNameController.clear();
      _genreController.clear();
      _reviewController.clear();

      Navigator.of(context).pop();
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add review: $e")),
      );
    }
  }

  void _deleteReview(int index){
    setState(() {
      reviews.removeAt(index);
    });
    _saveReviews();
  }     

  void _showAddReviewDialog(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Add Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _movieNameController,
              decoration: InputDecoration(labelText: 'Movie Name'),
            ),
            TextField(
              controller: _genreController,
              decoration: InputDecoration(labelText: 'Genre'),
            ),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              maxLength: 180,
              decoration: InputDecoration(labelText: 'Review (180 characters max)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addReview, child: Text('Add')),
        ],
      );
    },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Review App',
          style: TextStyle(
            color: Color(0xFFC9CAD9),
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF171738),
      ),
      body: _isLoading
      ? Center(child: CircularProgressIndicator())
      : _errorMessage != null
      ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _loadReviews,
              child: Text('Retry'),
            )
          ],
        ),
      )
    : reviews.isEmpty
    ? Center(
      child: Text(
        'No Reviews Yet. Tap "+" to add one',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF171738),
        ),
      ),
    )

    : ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['movieName']!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Genre: ${review['genre']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    review['review']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    _deleteReview(index); 
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        backgroundColor: Color(0xFF171738),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Add Review',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF171738)),
        ),
      ),
    );
  }
}
