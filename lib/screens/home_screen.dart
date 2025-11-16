import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/image_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/image_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ImageProvider>();
      provider.checkServer();
      provider.loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Search'),
        elevation: 0,
      ),
      body: Consumer<ImageProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SearchBar(
                      onSearch: (query) {
                        provider.searchImages(query);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (!provider.serverConnected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Server not connected',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error.isNotEmpty
                        ? Center(child: Text('Error: ${provider.error}'))
                        : ImageGrid(
                            images: provider.searchResults.isNotEmpty
                                ? provider.searchResults
                                : provider.images,
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
