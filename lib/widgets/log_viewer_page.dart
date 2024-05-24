import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../injection.dart';

class LogViewerPage extends StatefulWidget {
  @override
  _LogViewerPageState createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  List<OutputEvent> logs = [];

  @override
  void initState() {
    super.initState();
    logs = memoryLogOutput.logs;
  }

  @override
  Widget build(BuildContext context) {
    var logs = memoryLogOutput.logs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Viewer'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final event = logs[index];
          return ListTile(
            title: Text(event.level.toString()),
            subtitle: Text(event.lines.join('\n')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () {
          memoryLogOutput.clearLogs();
          setState(() {
            logs = memoryLogOutput.logs;
          });
        },
      ),
      // body: ListView.builder(
      //   itemCount: logs.length,
      //   itemBuilder: (context, index) {
      //     final event = logs[index];
      //     return ListTile(
      //       title: Text(event.level.toString()),
      //       subtitle: Text(event.lines.join('\n')),
      //     );
      //   },
      // ),
    );
  }
}

class MemoryLogOutput extends LogOutput {
  final List<OutputEvent> _logs = [];

  List<OutputEvent> get logs => _logs;

  @override
  void output(OutputEvent event) {
    _logs.add(event);
  }

  void clearLogs() {
    _logs.clear();
  }
}
