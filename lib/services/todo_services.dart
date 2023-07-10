import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = "https://pg-cms.aruna.id/api";

class TodoService {
  static Future<Map<String, dynamic>> deleteById(int id) async {
    final url = '$baseUrl/todos/$id';
    final uri = Uri.parse(url);
    final resp = await http.delete(uri);

    if (resp.statusCode == 200) {
      return {"isError": false, "msg": "Success Delete Todo"};
    }

    return {
      "isError": true,
      "msg": '${(jsonDecode(resp.body) as Map)["message"]}'
    };
  }

  static Future<Map<String, dynamic>> getAllTodos() async {
    const url = "$baseUrl/todos";
    final uri = Uri.parse(url);
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map;
      final result = json["data"] != null ? json["data"] as List : [];

      return {"isError": false, "data": result};
    }

    return {
      "isError": true,
      "msg": '${jsonDecode(resp.body) as Map}',
    };
  }

  static Future<Map<String, dynamic>> addTodo(Map<String, dynamic> body) async {
    const url = "$baseUrl/todos";
    final uri = Uri.parse(url);

    final resp = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (resp.statusCode == 200) {
      return {"isError": false, "msg": "Success Add Todo"};
    }

    return {
      "isError": true,
      "msg": '${(jsonDecode(resp.body) as Map)["message"]}'
    };
  }

  static Future<Map<String, dynamic>> updateTodo(
      int id, Map<String, dynamic> body) async {
    final url = "$baseUrl/todos/$id";
    final uri = Uri.parse(url);

    final resp = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (resp.statusCode == 200) {
      return {"isError": false, "msg": "Success Update Todo"};
    }

    return {
      "isError": true,
      "msg": '${(jsonDecode(resp.body) as Map)["message"]}'
    };
  }
}
