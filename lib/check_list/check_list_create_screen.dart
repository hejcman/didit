import 'package:flutter/material.dart';
import '../common/platformization.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

class CheckListCreateScreen extends StatefulWidget {
  final VoidCallback onCreated;

  const CheckListCreateScreen({Key? key, required this.onCreated}) : super(key: key);

  @override
  State<CheckListCreateScreen> createState() => _CheckListCreateScreenState();
}

class _CheckListCreateScreenState extends State<CheckListCreateScreen> {
  final nameInputController = TextEditingController();
  List<String> items = [];
  String checkListName = "";

  void _addItemToItemsList(String item) {
    setState(() {
      items.add(item);
    });
  }

  void _removeItemAtIndex(int index) {
    setState(() {
      items.removeAt(index);
    });
  }
  
  List<CheckListItem> _makeCheckListItems() {
    List<CheckListItem> list = [];
    list = items.map((title) => CheckListItem(items.indexOf(title), title)).toList();
    return list;
  }

  void _saveCheckList() {
    // Create memory from the image
    final CheckList checkList = CheckList(
      checkListName,
      DateTime.now(),
      _makeCheckListItems()
    );

    createCheckList(checkList);

    widget.onCreated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create check list",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple[400]
          ),
        ),
        leading: IconButton(
          icon: Icon(getBackArrowIcon()),
          color: Theme.of(context).colorScheme.onBackground,
          onPressed: () async {
            Navigator.pop(context);
          }
        ),
        actions: [
          IconButton(
              icon: Icon(getSaveIcon()),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () => _saveCheckList(),
              tooltip: "Save new check list",
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: checkListName.isNotEmpty ?
        CheckListCreateForm(addItem: _addItemToItemsList, removeItem: _removeItemAtIndex) : null,
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    TextField(
                      controller: nameInputController,
                      onChanged: (newVal) {
                        setState(() {
                          checkListName = newVal;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a title for task list',
                        label: Text("Check list title")
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isNotEmpty ? ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final String item = items.removeAt(oldIndex);
                      items.insert(newIndex, item);
                    });
                  },
                  itemCount: items.length,
                  itemBuilder: (context, index) => ListTile(
                    key: Key('$index'),
                    leading: Text(
                      "${index+1}.",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple[400]
                      ),
                    ),
                    title: Text(items[index]),
                    trailing: TextButton(
                      onPressed: () => _removeItemAtIndex(index),
                      child: Icon(
                          getMinusIcon(),
                          size: 30.0
                      ),
                    ),
                  )
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("List is empty"),
                      checkListName.isNotEmpty ?
                        const Text("You should add some tasks down below.") :
                          const Text("First give your check list a title above.")
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}

class CheckListCreateForm extends StatefulWidget {
  final ValueChanged<String> addItem;
  final ValueChanged<int> removeItem;

  const CheckListCreateForm({Key? key, required this.addItem, required this.removeItem}) : super(key: key);

  @override
  State<CheckListCreateForm> createState() => _CheckListCreateFormState();
}

class _CheckListCreateFormState extends State<CheckListCreateForm> {
  final inputController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: inputController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a task name or description',
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              final inputTask = inputController.text;
              widget.addItem(inputTask);
              inputController.clear();
            },
            child: Icon(getPlusIcon()),
          ),
        ],
      ),
    );
  }
}

