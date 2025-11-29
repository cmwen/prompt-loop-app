import 'package:flutter/material.dart';

// Available services (uncomment to use):
// import 'package:min_flutter_template/services/storage_service.dart';
// import 'package:min_flutter_template/services/network_service.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// AI CUSTOMIZATION:
/// - Change `title` to your app name
/// - Modify `colorScheme` seedColor to change the app's primary color
/// - Replace `MyHomePage` with your own home screen widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App', // TODO: Change to your app name
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My App'), // TODO: Change to your app name
    );
  }
}

/// The home page of the application.
///
/// AI CUSTOMIZATION:
/// - Rename this class and file for your app
/// - Replace the counter example with your own UI
/// - Add navigation to other screens as needed
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
