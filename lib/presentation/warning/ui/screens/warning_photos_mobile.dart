import 'package:flutter/material.dart';

class WarningPhotosMobile extends StatelessWidget {
  const WarningPhotosMobile({Key? key, required this.images, required this.isLoading}) : super(key: key);
  final List<String> images;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning Photos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:isLoading ? Center(
          child: CircularProgressIndicator(),
        ): images.isEmpty
            ? Center(
                child: Text("No warning photos submitted!!!"),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount:
                    images.length, // Replace with the actual number of images
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      images[index], // Replace with actual image URL
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
