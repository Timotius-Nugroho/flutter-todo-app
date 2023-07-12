import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:todo_app/services/todo_services.dart';
import 'package:todo_app/utils/snackbar_helper.dart';
import 'package:todo_app/widget/todo_card.dart';
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
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: Center(
            child: Image.asset(
              "assets/images/empty.png",
              height: 100,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: fetchToDos,
            child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  return TodoCard(
                    index: index,
                    item: item,
                    navigateToEditPage: navigateToEditPage,
                    deleteById: deleteById,
                    toggleMark: toggleMark,
                  );
                }),
          ),
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
    try {
      final resp = await TodoService.getAllTodos();
      setState(() {
        isLoading = false;
      });

      if (!resp["isError"]) {
        setState(() {
          items = resp["data"];
        });
        return;
      }

      if (context.mounted) {
        showErrorMsg(context, message: resp["msg"]);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorMsg(context, message: '$e');
      }
    }
  }

  Future<void> deleteById(int id) async {
    final resp = await TodoService.deleteById(id);

    if (!resp["isError"]) {
      if (context.mounted) {
        showSuccessMsg(context, message: "Success delete todo!");
      }
      final filtered = items.where((element) => element["id"] != id).toList();
      setState(() {
        items = filtered;
      });
      return;
    }

    if (context.mounted) {
      showErrorMsg(context, message: resp["msg"]);
    }
  }

  Future<void> toggleMark(int index) async {
    final tempItems = items;
    tempItems[index]["attributes"]["is_completed"] =
        !tempItems[index]["attributes"]["is_completed"];

    final resp = await TodoService.updateTodo(tempItems[index]["id"], {
      "data": {
        "title": tempItems[index]["attributes"]["title"],
        "description": tempItems[index]["attributes"]["description"],
        "is_completed": tempItems[index]["attributes"]["is_completed"]
      }
    });

    if (resp["isError"]) {
      if (context.mounted) {
        showErrorMsg(context, message: "Failed to mark as done!");
      }
      return;
    }

    setState(() {
      items = tempItems;
    });
  }
}
