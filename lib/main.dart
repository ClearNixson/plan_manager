import 'package:flutter/material.dart';

void main() {
  runApp(PlanManagerApp());
}

class PlanManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  String priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = 'Low',
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      plans.add(
        Plan(
          name: name,
          description: description,
          date: date,
          priority: priority,
        )
      );
    });
  }

  void _updatePlan(int index, String name, String description, DateTime date, String priority) {
    setState(() {
      plans[index].name = name;
      plans[index].description = description;
      plans[index].date = date;
      plans[index].priority = priority;
    });
  }

  void _togglePlanCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _showAddPlanModal() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime selectDate = DateTime.now();
    String selectPriority = 'Low';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Plan Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  Row(
                    children: [
                      Text('Date : ${selectDate.toLocal()}'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pick = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2125),
                          );
                          if (pick != null && pick != selectDate) {
                            setModalState(() {
                              selectDate = pick;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: selectPriority,
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectPriority = newValue!;
                      });
                    },
                    items: <String>['Low', 'Medium', 'High']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addPlan(
                        nameController.text,
                        descriptionController.text,
                        selectDate,
                        selectPriority,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Add Plan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPlanModal(int index) {
    TextEditingController nameController = TextEditingController(text: plans[index].name);
    TextEditingController descriptionController = TextEditingController(text: plans[index].description);
    DateTime selectDate = plans[index].date;
    String selectPriority = plans[index].priority;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Plan Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  Row(
                    children: [
                      Text('Date: ${selectDate.toLocal()}'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pick = await showDatePicker(
                            context: context,
                            initialDate: selectDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2125),
                          );
                          if (pick != null && pick != selectDate) {
                            setModalState(() {
                              selectDate = pick;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: selectPriority,
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectPriority = newValue!;
                      });
                    },
                    items: <String>['Low', 'Medium', 'High']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                        );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePlan(
                        index,
                        nameController.text,
                        descriptionController.text,
                        selectDate,
                        selectPriority,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Update Plan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Manager'),
      ),
      body: ReorderableListView.builder(
        itemCount: plans.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Plan plan = plans.removeAt(oldIndex);
            plans.insert(newIndex, plan);
          });
        },
        itemBuilder: (BuildContext context, int index) {
          final plan = plans[index];
          return Dismissible(
            key: Key(plan.name),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.check, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: Icon(Icons.delete, color: Colors.white,),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _togglePlanCompletion(index);
              }
              else {
                _deletePlan(index);
              }
            },
            child: ListTile(
              title: Text(plan.name),
              subtitle: Text('${plan.description} - ${plan.date.toLocal()}'),
              trailing: Text(plan.priority),
              tileColor: plan.isCompleted ? Colors.green : null,
              onLongPress: () => _showEditPlanModal(index),
              onTap: () {
                if (plan.isCompleted) {
                  _togglePlanCompletion(index);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanModal,
        child: Icon(Icons.add),
      ),
    );
  }
}