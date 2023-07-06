import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      isEdit = true;
      titleController.text = widget.todo?["attributes"]?["title"] ?? "";
      descController.text = widget.todo?["attributes"]?["description"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          TextField(
            decoration: const InputDecoration(hintText: "Title"),
            controller: titleController,
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(isEdit ? "Update" : "Submit"),
              ))
        ],
      ),
    );
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final desc = descController.text;
    final body = {
      "data": {"title": title, "description": desc, "is_completed": false}
    };

    const url = "https://pg-cms.aruna.id/api/todos";
    final uri = Uri.parse(url);
    final resp = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (resp.statusCode == 200) {
      titleController.text = "";
      descController.text = "";
      showSuccessMsg("Todo Created!");
      return;
    }

    showErrorMsg('${(jsonDecode(resp.body) as Map)}');
  }

  Future<void> updateData() async {
    if (widget.todo == null) {
      return;
    }

    final id = widget.todo?["id"];
    final title = titleController.text;
    final desc = descController.text;
    final body = {
      "data": {
        "title": title,
        "description": desc,
        "is_completed": widget.todo?["attributes"]?["is_completed"] ?? false
      }
    };

    final url = "https://pg-cms.aruna.id/api/todos/$id";
    final uri = Uri.parse(url);
    final resp = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (resp.statusCode == 200) {
      showSuccessMsg("Todo Updated!");
      return;
    }

    showErrorMsg('${(jsonDecode(resp.body))}');
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
