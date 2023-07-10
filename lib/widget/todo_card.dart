import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final int index;
  final Map item;
  final Function(Map) navigateToEditPage;
  final Function(int) deleteById;

  const TodoCard({
    super.key,
    required this.index,
    required this.item,
    required this.navigateToEditPage,
    required this.deleteById,
  });

  @override
  Widget build(BuildContext context) {
    final id = item["id"] as int;

    return Card(
      margin: const EdgeInsets.all(4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(item["attributes"]["title"]),
        subtitle: Text(item["attributes"]["description"]),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == "edit") {
              navigateToEditPage(item);
            } else if (value == "delete") {
              deleteById(id);
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: "edit",
                child: Text("Edit"),
              ),
              const PopupMenuItem(
                value: "delete",
                child: Text("Delete"),
              )
            ];
          },
        ),
      ),
    );
  }
}
