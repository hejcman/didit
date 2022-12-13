import 'package:flutter/material.dart';
import 'package:didit/common/platformization.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

class CheckListCaptureScreen extends StatefulWidget {
  final CheckList checkList;
  final VoidCallback? onDeleted;

  const CheckListCaptureScreen({super.key, required this.checkList, this.onDeleted});

  @override
  State<CheckListCaptureScreen> createState() => _CheckListCaptureScreenState();
}

class _CheckListCaptureScreenState extends State<CheckListCaptureScreen> {
  CheckList? checkList;

  void delete() async {
    Navigator.of(context).pop();
    deleteCheckList(widget.checkList);
    widget.onDeleted!();
  }

  @override
  void initState() {
    checkList = getCheckListsBox().get(widget.checkList.key);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          checkList!.title,
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
              icon: Icon(getReloadIcon()),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () {}
          ),
          IconButton(
              icon: Icon(getDeleteIcon()),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () {
                delete();
              }
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.deepPurple[800],
                    indent: 5,
                    endIndent: 5,
                  ),
                  itemCount: checkList!.items.length,
                  itemBuilder: (context, index) => CheckListItem(index: index, title: checkList!.items.elementAt(index).title),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}

class CheckListItem extends StatelessWidget {
  final int index;
  final String title;
  final bool checked;

  const CheckListItem({Key? key, required this.index, required this.title, this.checked = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Text(
                "${index+1}.",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple[400],
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            FittedBox(
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20)
                  ),
                  child: Icon(
                    checked ? getCheckIcon() : getCameraIcon(),
                    size: 30.0
                  ),
                ),
              ),
            )],
        )
    );
  }
}

