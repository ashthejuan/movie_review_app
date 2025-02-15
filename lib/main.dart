import 'package:flutter/material.dart';

void main() {
  runApp(MovieReviewApp());
}

class MovieReviewApp extends StatelessWidget {
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
  @override
  _MovieReviewScreenState createState() => _MovieReviewScreenState();
}

class _MovieReviewScreenState extends State<MovieReviewScreen> {
  List<Map<String, String>> reviews = [];


  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _reviewContoller = TextEditingController();

  void _addReview(){
    if (_movieNameController.text.isNotEmpty && 
        _genreController.text.isNotEmpty &&
        _reviewContoller.text.isNotEmpty){
          setState(() {
            reviews.add({
              'movieName': _movieNameController.text,
              'genre': _genreController.text,
              'review': _reviewContoller.text,
            });
          });

          _movieNameController.clear();
          _genreController.clear();
          _reviewContoller.clear();

          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all fields')),
          );
        }
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
              controller: _reviewContoller,
              maxLines: 3,
              maxLength: 180,
              decoration: InputDecoration(labelText: 'Review (180 words max)'),
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
        title: Text('Movie Review App'),
        backgroundColor: Color(0xFF171738),
      ),
      body: reviews.isEmpty ? Center(
        child: Text(
          'No reviews yet. Tap "+" to add one.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF171738)),
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
          child: Column(
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
