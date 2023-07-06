import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:http/http.dart' as http;
// import 'dart:developer';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchToDos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Todo List"),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text("Add Todo")),
      body: Visibility(
        visible: !isLoading,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: RefreshIndicator(
          onRefresh: fetchToDos,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item["id"] as int;

                return ListTile(
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
                );
              }),
        ),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDos();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route =
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDos();
  }

  Future<void> fetchToDos() async {
    const url = "https://pg-cms.aruna.id/api/todos";
    final uri = Uri.parse(url);
    final resp = await http.get(uri);
    setState(() {
      isLoading = false;
    });

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map;
      final result = json["data"] != null ? json["data"] as List : [];

      setState(() {
        items = result;
        // log(jsonEncode(items));
      });
      return;
    }

    showErrorMsg('${(jsonDecode(resp.body) as Map)}');
  }

  Future<void> deleteById(int id) async {
    final url = 'https://pg-cms.aruna.id/api/todos/$id';
    final uri = Uri.parse(url);
    final resp = await http.delete(uri);

    if (resp.statusCode == 200) {
      showSuccessMsg("Success delete todo!");
      final filtered = items.where((element) => element["id"] != id).toList();
      setState(() {
        items = filtered;
      });
      return;
    }

    showErrorMsg('${(jsonDecode(resp.body) as Map)["message"]}');
  }

  void showSuccessMsg(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMsg(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
