import 'package:flutter/material.dart';

void main() => runApp(const DismissibleDemoApp());

class DismissibleDemoApp extends StatelessWidget {
  const DismissibleDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dismissible Demo',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Colors.deepPurple,
          secondary: Colors.tealAccent,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
        ),
      ),
      home: const DismissibleListScreen(),
    );
  }
}

class DismissibleListScreen extends StatefulWidget {
  const DismissibleListScreen({super.key});

  @override
  State<DismissibleListScreen> createState() => _DismissibleListScreenState();
}

class _DismissibleListScreenState extends State<DismissibleListScreen> {
  final List<String> _items = List.generate(10, (i) => 'Task ${i + 1}');
  final List<Color> _colors = [
    Colors.deepPurple,
    Colors.teal,
    Colors.blueAccent,
    Colors.pinkAccent,
    Colors.amber,
    Colors.indigoAccent,
    Colors.cyan,
    Colors.limeAccent,
    Colors.redAccent,
    Colors.greenAccent,
  ];

  void _removeItem(int index) {
    final removedItem = _items[index];
    final removedIndex = index;
    final removedColor = _colors[index];

    setState(() {
      _items.removeAt(index);
      _colors.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$removedItem"'),
        backgroundColor: Colors.grey.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade800),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.tealAccent,
          onPressed: () {
            setState(() {
              _items.insert(removedIndex, removedItem);
              _colors.insert(removedIndex, removedColor);
            });
          },
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, Alignment alignment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, DismissDirection direction) async {
    final isArchive = direction == DismissDirection.startToEnd;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800),
        ),
        title: Text(
          isArchive ? 'Archive Item?' : 'Delete Item?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          isArchive 
              ? 'This will move the item to archives'
              : 'This will permanently remove the item',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isArchive ? 'ARCHIVE' : 'DELETE',
              style: TextStyle(
                color: isArchive ? Colors.tealAccent : Colors.redAccent,
                fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              setState(() {
                _items.add('Task ${_items.length + 1}');
                _colors.add(Colors.primaries[_items.length % Colors.primaries.length]);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Dismissible(
              key: Key('${_items[index]}_$index'),
              direction: DismissDirection.horizontal,
              // Swipe RIGHT (startToEnd) shows Archive (teal)
              background: _buildSwipeBackground(
                Colors.teal.shade800.withOpacity(0.9),
                Icons.archive,
                Alignment.centerLeft,
              ),
              // Swipe LEFT (endToStart) shows Delete (red)
              secondaryBackground: _buildSwipeBackground(
                Colors.red.shade800.withOpacity(0.9),
                Icons.delete,
                Alignment.centerRight,
              ),
              confirmDismiss: (direction) => _showConfirmationDialog(context, direction),
              onDismissed: (_) => _removeItem(index),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _colors[index].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _colors[index].withOpacity(0.5)),
                    ),
                    child: Icon(Icons.task, color: _colors[index]),
                  ),
                  title: Text(
                    _items[index],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Swipe left to delete • right to archive',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.drag_handle,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}