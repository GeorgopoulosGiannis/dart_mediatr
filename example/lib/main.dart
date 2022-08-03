import 'package:example/add_item_command.dart';
import 'package:example/get_items_query.dart';
import 'package:example/setup_mediator.dart';
import 'package:flutter/material.dart';

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

    final addedOrFailure =
        await mediator.send<void, AddItemCommand>(AddItemCommand(itemToAdd));
    addedOrFailure.fold(
      (left) {
        print("Failed to add item");

        setState(() {
          error = left.message;
        });
      },
      (right) {
        print("Item succesfully added");
        _controller.clear();
      },
    );
  }

  Future<void> getItems() async {
    final itemsOrFailure =
        await mediator.send<List<String>, GetItemsQuery>(GetItemsQuery());
    itemsOrFailure.fold(
      (left) {
        print('Failed to get items');
      },
      (right) {
        print('Got items');

        setState(() {
          items = right;
        });
      },
    );
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
                      child: Text(
                        'AddItem',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: TextField(
                      controller: _controller,
                      onChanged: (val) {
                        print(val);
                      },
                      decoration: InputDecoration(
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
              child: Text(
                'GetItems',
              ),
            ),
            if (error != null)
              Center(
                child: Text(
                  error!,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            Center(
              child: Text(
                'Items',
                style: Theme.of(context).textTheme.headline6,
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
