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
  final _nameInputController = TextEditingController();
  bool _nameInputDisplayError = false;

  List<String> items = [];
  bool _itemsEmptyDisplayError = false;
  String checkListName = "";

  void _addItemToItemsList(String item) {
    if (item == "") {
      return;
    }

    setState(() {
      items.add(item);
      if (items.isNotEmpty && _itemsEmptyDisplayError) {
        _itemsEmptyDisplayError = false;
      }
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
    if (checkListName == "") {
      if (!_nameInputDisplayError) {
        setState(() {
          _nameInputDisplayError = true;
        });
      }
      return;
    }

    if (items.isEmpty) {
      if (!_itemsEmptyDisplayError) {
        _itemsEmptyDisplayError = true;
      }
      return;
    }

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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create check list",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground
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
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameInputController,
                      onChanged: (newVal) {
                        setState(() {
                          checkListName = newVal;
                          if (newVal == "") {
                            _nameInputDisplayError = true;
                          } else {
                            if (_nameInputDisplayError) {
                              _nameInputDisplayError = false;
                            }
                          }
                        });
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter a title for task list',
                        label: const Text("Check list title"),
                        errorText: _nameInputDisplayError ? 'Title can\'t be empty' : null,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isNotEmpty ? ReorderableListView.builder(
                  shrinkWrap: true,
                  anchor: 0,
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
              CheckListCreateForm(
                  addItem: _addItemToItemsList,
                  removeItem: _removeItemAtIndex,
                  titleEmpty: checkListName.isEmpty,
                  itemsEmpty: _itemsEmptyDisplayError,
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
  final bool titleEmpty;
  final bool itemsEmpty;

  const CheckListCreateForm(
      {
        Key? key,
        required this.addItem,
        required this.removeItem,
        this.titleEmpty = false,
        this.itemsEmpty = false
      }
      ) : super(key: key);

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
                enabled: !widget.titleEmpty,
                controller: inputController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter a task name or description',
                  errorText: widget.itemsEmpty ? "Add at least 1 task to your list" : null
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

