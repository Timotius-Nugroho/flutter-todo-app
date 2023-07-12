import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoCard extends StatefulWidget {
  final int index;
  final Map item;
  final Function(Map) navigateToEditPage;
  final Function(int) deleteById;
  final Function(int) toggleMark;

  const TodoCard({
    super.key,
    required this.index,
    required this.item,
    required this.navigateToEditPage,
    required this.deleteById,
    required this.toggleMark,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool isToggeling = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.item["id"] as int;
    final isCompleted = widget.item["attributes"]["is_completed"] as bool;

    return Card(
      child: Slidable(
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
          SlidableAction(
            onPressed: (context) {
              widget.deleteById(id);
            },
            icon: Icons.delete,
            backgroundColor: const Color.fromARGB(255, 174, 73, 65),
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(
            height: 20,
            width: 5,
          ),
          SlidableAction(
            onPressed: (context) {
              widget.navigateToEditPage(widget.item);
            },
            icon: Icons.edit,
            backgroundColor: const Color.fromARGB(255, 233, 222, 129),
            borderRadius: BorderRadius.circular(12),
          ),
        ]),
        child: ListTile(
            leading: CircleAvatar(
              child: Text('${widget.index + 1}'),
            ),
            title: Text(
              widget.item["attributes"]["title"],
              style: TextStyle(
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            ),
            subtitle: Text(widget.item["attributes"]["description"]),
            trailing: Visibility(
              visible: !isToggeling,
              replacement: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ),
              ),
              child: Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  doToggle(widget.index);
                },
                activeColor: Colors.black,
              ),
            )),
      ),
    );
  }

  Future<void> doToggle(int index) async {
    setState(() {
      isToggeling = true;
    });
    await widget.toggleMark(index);
    setState(() {
      isToggeling = false;
    });
  }
}
