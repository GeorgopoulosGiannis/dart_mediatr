import 'package:flutter/material.dart';

import 'add_item_command.dart';
import 'get_items_query.dart';
import 'setup_mediator.dart';

void main() {
  runApp(const MyApp());
}

final mediator = setupMediator();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediator demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Mediator Demo Home Page'),
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
  final _controller = TextEditingController();

  List<String> items = [];
  String? error;

  Future<void> addItem() async {
    final itemToAdd = _controller.text;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      error = null;
    });

    try {
      await mediator.send<AddItemCommand, void>(AddItemCommand(itemToAdd));

      _controller.clear();
    } on EmptyItemException {
      setState(() {
        error = 'Cannot add empty item';
      });
    }
  }

  Future<void> getItems() async {
    try {
      final result =
          await mediator.send<GetItemsQuery, List<String>>(GetItemsQuery());

      setState(() {
        items = result;
      });
    } on EmptyItemException {
      setState(() {
        error = 'Cannot get items';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: addItem,
                      child: const Text(
                        'AddItem',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: TextField(
                      controller: _controller,
                      onChanged: (val) {
                        print(val);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter item',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: getItems,
              child: const Text(
                'GetItems',
              ),
            ),
            if (error != null)
              Center(
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            Center(
              child: Text(
                'Items',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Flexible(
              child: ItemsList(
                items: items,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemsList extends StatelessWidget {
  final List<String> items;
  const ItemsList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              items[index],
            ),
          );
        },
      );
}
