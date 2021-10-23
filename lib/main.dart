import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ffcache/ffcache.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FFCache web support test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _cache = FFCache(debug: true);
  List<Widget> _results = [];

  void _runTests() async {
    _clearResults();
    var currentTest = 'init()';
    try {
      await _cache.init();
      _addTestResult(currentTest, true);
      // ---
      currentTest = 'setString';
      const testString = 'test_string';
      await _cache.setString('string', testString);
      _addTestResult(currentTest, true);
      // ---
      currentTest = 'getString';
      final stringTestPassed = await _cache.getString('string') == testString;
      _addTestResult(currentTest, stringTestPassed);
      // ---
      currentTest = 'setJSON';
      final testJson = jsonDecode(
          '{"id":1,"data":"string data","nested":{"id":"hello","flutter":"rocks"}}');
      await _cache.setJSON('json', testJson);
      _addTestResult(currentTest, true);
      // ---
      currentTest = 'getJSON';
      final jsonTestPassed = (await _cache.getJSON('json'))['id'] == 1;
      _addTestResult(currentTest, jsonTestPassed);
      // ---
      currentTest = 'setStringWithTimeout & read back';
      const timeout = 512;
      await _cache.setStringWithTimeout(
          'timeout_string', testString, const Duration(milliseconds: timeout));
      await Future.delayed(const Duration(milliseconds: timeout ~/ 2))
          .then((_) async {
        final passed = await _cache.getString('timeout_string') == testString;
        _addTestResult(currentTest, passed);
      });
      // ---
      currentTest = 'wait prev. timeout & expect null';
      await Future.delayed(const Duration(milliseconds: timeout))
          .then((_) async {
        final passed = await _cache.getString('timeout_string') == null;
        _addTestResult(currentTest, passed);
      });
      // ---
      currentTest = 'setBytes';
      await _cache.setBytes('bytes', [222, 173, 190, 239]);
      _addTestResult(currentTest, true);
      // ---
      currentTest = 'getBytes';
      final bytes = await _cache.getBytes('bytes');
      _addTestResult(currentTest, bytes?[0] == 222);
    } catch (err) {
      print(err);
      _addTestResult(currentTest, false, err: err.toString());
    }
  }

  void _clearResults() {
    setState(() {
      _results.clear();
    });
  }

  void _addTestResult(String caption, bool pass, {String err = ''}) {
    setState(() {
      _results.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(caption),
            Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                pass ? 'PASS' : 'FAIL',
                style: const TextStyle(color: Colors.white),
              ),
              color: pass ? Colors.green : Colors.deepOrange,
            ),
          ],
        ),
      ));
      if (err.isNotEmpty) {
        _results.add(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Text(err),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          width: 360,
          height: double.infinity,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start, children: _results),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runTests,
        tooltip: 'Run Tests',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
