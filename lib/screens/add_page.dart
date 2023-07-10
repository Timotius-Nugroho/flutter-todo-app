import 'package:flutter/material.dart';
import 'package:todo_app/services/todo_services.dart';
import 'package:todo_app/utils/snackbar_helper.dart';

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
  bool isLoading = false;

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
              onPressed: isLoading
                  ? null
                  : isEdit
                      ? updateData
                      : submitData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(isEdit ? "Update" : "Submit"),
              )),
        ],
      ),
    );
  }

  Future<void> submitData() async {
    setState(() {
      isLoading = true;
    });

    final resp = await TodoService.addTodo(body);
    setState(() {
      isLoading = false;
    });
    if (!resp["isError"]) {
      titleController.text = "";
      descController.text = "";

      if (context.mounted) {
        showSuccessMsg(context, message: "Todo Created!");
      }
      return;
    }

    if (context.mounted) {
      showErrorMsg(context, message: resp["msg"]);
    }
  }

  Future<void> updateData() async {
    if (widget.todo == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final id = widget.todo?["id"];
    final resp = await TodoService.updateTodo(id, body);
    setState(() {
      isLoading = false;
    });
    if (!resp["isError"]) {
      if (context.mounted) {
        showSuccessMsg(context, message: "Todo Created!");
      }
      return;
    }

    if (context.mounted) {
      showErrorMsg(context, message: resp["msg"]);
    }
  }

  Map<String, dynamic> get body {
    final title = titleController.text;
    final desc = descController.text;

    return {
      "data": {
        "title": title,
        "description": desc,
        "is_completed": widget.todo?["attributes"]?["is_completed"] ?? false
      }
    };
  }
}
