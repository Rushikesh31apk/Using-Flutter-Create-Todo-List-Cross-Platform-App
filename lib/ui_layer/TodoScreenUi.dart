import 'package:flutter/material.dart';
import '../data_layer/local_database/DbHelper.dart';
import 'UiHelper.dart';

class TodoScreenUi extends StatefulWidget {
  const TodoScreenUi({super.key});

  @override
  State<TodoScreenUi> createState() => _TodoScreenUiState();
}

class _TodoScreenUiState extends State<TodoScreenUi> {
  List<Map<String, dynamic>> allTodos = [];
  List<Map<String, dynamic>> filteredTodos = [];
  int currentTabIndex = 0;
  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getTodos();
  }

  void getTodos() async {
    allTodos = await dbRef!.getAlltodo();
    filterTodos();
  }

  void filterTodos() {
    setState(() {
      if (currentTabIndex == 0) {
        filteredTodos = allTodos;
      } else if (currentTabIndex == 1) {
        filteredTodos = allTodos.where((todo) => todo[DbHelper.status] == 1).toList();
      } else if (currentTabIndex == 2) {
        filteredTodos = allTodos.where((todo) => todo[DbHelper.status] == 0).toList();
      }
    });
  }

  void updateStatus(int id, int status, String title, String desc) async {
    await dbRef?.updateTodo(
      id: id,
      mtitle: title,
      mdesc: desc,
      mstatus: status,
    );
    getTodos();
  }

  void showTodoBottomSheet({
    required BuildContext context,
    String title = 'Add Todo',
    Map<String, dynamic>? todo,
    required VoidCallback onSave,
    required TextEditingController titleController,
    required TextEditingController descController,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              UiHelper.buildTextField(
                controller: titleController,
                label: 'Title',
              ),
              SizedBox(height: 15),
              UiHelper.buildTextField(
                controller: descController,
                label: 'Description',
                isMultiline: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UiHelper.buildButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                  UiHelper.buildButton(
                    text: 'Save',
                    onPressed: onSave,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Todo List',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          final descController = TextEditingController();
          showTodoBottomSheet(
            context: context,
            titleController: titleController,
            descController: descController,
            onSave: () async {
              if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                await dbRef?.addTodo(
                  mtitle: titleController.text,
                  mdesc: descController.text,
                  mstatus: 0,
                );
                getTodos();
                Navigator.pop(context);
              }
            },
          );
        },
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add),
      ),
      body: filteredTodos.isNotEmpty
          ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (_, index) {
            final todo = filteredTodos[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black54),
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    todo[DbHelper.status] == 1
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: todo[DbHelper.status] == 1 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => updateStatus(
                    todo[DbHelper.id],
                    todo[DbHelper.status] == 1 ? 0 : 1,
                    todo[DbHelper.title],
                    todo[DbHelper.desc],
                  ),
                ),
                title: Text(
                  todo[DbHelper.title],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todo[DbHelper.desc]),
                    Text(
                      todo[DbHelper.status] == 1 ? "Completed" : "Incomplete",
                      style: TextStyle(
                        color: todo[DbHelper.status] == 1 ? Colors.green : Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        final titleController =
                        TextEditingController(text: todo[DbHelper.title]);
                        final descController =
                        TextEditingController(text: todo[DbHelper.desc]);
                        showTodoBottomSheet(
                          context: context,
                          title: 'Edit Todo',
                          titleController: titleController,
                          descController: descController,
                          onSave: () async {
                            if (titleController.text.isNotEmpty &&
                                descController.text.isNotEmpty) {
                              await dbRef?.updateTodo(
                                id: todo[DbHelper.id],
                                mtitle: titleController.text,
                                mdesc: descController.text,
                                mstatus: todo[DbHelper.status],
                              );
                              getTodos();
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await dbRef?.deleteTodo(
                          id: todo[DbHelper.id],
                        );
                        getTodos();
                      },
                    ),
                  ],
                ),
              ),
            );
                    },
                  ),
          )
          : Center(
        child: Text(
          'Your todo list is empty!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          currentTabIndex = index;
          filterTodos();
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle, color: Colors.green),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel, color: Colors.red),
            label: 'Incomplete',
          ),
        ],
      ),
    );
  }
}
