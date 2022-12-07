import 'package:flutter/material.dart';
import 'package:didit/common/platformization.dart';

import 'check_list_create_screen.dart';
import 'check_list_capture_screen.dart';

// Storage
import '../storage/adapters.dart';
import '../storage/schema.dart';

class CheckListOverviewScreen extends StatefulWidget {
  const CheckListOverviewScreen({Key? key}) : super(key: key);

  @override
  State<CheckListOverviewScreen> createState() => _CheckListOverviewScreenState();
}

class _CheckListOverviewScreenState extends State<CheckListOverviewScreen> {
  List<CheckList> checkLists = getCheckLists();

  @override
  void initState() {
    checkLists = getCheckLists();
    super.initState();
  }

  void _refreshList() {
    setState(() {
      checkLists = getCheckLists();
    });
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
          "Check lists",
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => CheckListCreateScreen(onCreated: _refreshList,)));
        },
        label: const Text('New check list'),
        icon: Icon(getPlusIcon()),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: const [
                    Text("List title:"),
                    Spacer(),
                    Text("Done tasks:")
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.deepPurple[800],
                    indent: 10,
                    endIndent: 10,
                  ),
                  itemCount: checkLists.length,
                  itemBuilder: (context, index) => CheckListTab(
                    checkList: checkLists[index],
                    onCheckListDeleted: _refreshList,
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}

class CheckListTab extends StatefulWidget {
  /*final int index;
  final String title;
  final dynamic dbKey;
  final int steps;
  final int stepsDone;*/
  final CheckList checkList;
  final VoidCallback? onCheckListDeleted;

  const CheckListTab(
    {
      Key? key,
      required this.checkList,
      this.onCheckListDeleted,
      /*required this.index,
      required this.title,
      required this.dbKey,
      required this.steps,
      required this.stepsDone*/
    }
    ) : super(key: key);

  @override
  State<CheckListTab> createState() => _CheckListState();
}

class _CheckListState extends State<CheckListTab> {
  String getTrailingText() {
    /*if (widget.stepsDone == 0) {
      return "Begin check";
    } else if (widget.stepsDone == widget.steps) {
      return "Done";
    } else {
      return "${widget.stepsDone}/${widget.steps}";
    }*/
    return "0/${widget.checkList.items.length}";
  }

  @override
  Widget build(BuildContext context) {
    /*return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                widget.title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: Text(
              widget.stepsDone == 0 ? "Begin check" : "${widget.stepsDone}/${widget.steps}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple[400],
                fontSize: 18,
              ),
            ),
          ),
        ],
      )
    );*/
    return ListTile(
      onTap: () async {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => CheckListCaptureScreen(
                    checkList: widget.checkList,
                    onDeleted: widget.onCheckListDeleted
                )));
      },
      title: Text(widget.checkList.title),
      trailing: Text(
        getTrailingText(),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.deepPurple[400],
          fontSize: 18,
        ),
      ),
    );
  }
}

