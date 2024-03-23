import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khiem_vais_test/bloc/theme/theme_bloc.dart';
import 'package:khiem_vais_test/common/extensions.dart';
import 'package:khiem_vais_test/common/shared_prefs.dart';
import 'package:khiem_vais_test/model/status_filter.dart';
import 'package:khiem_vais_test/model/task.dart';
import 'package:khiem_vais_test/res/dimens.dart';
import 'package:khiem_vais_test/res/spacing.dart';
import 'package:khiem_vais_test/res/string.dart';
import 'package:khiem_vais_test/util/common_util.dart';

class ListTask extends StatefulWidget {
  const ListTask({super.key});

  @override
  State<ListTask> createState() => _ListTaskState();
}

class _ListTaskState extends State<ListTask> {
  int _currentDeadlineMillis = 0;
  late ThemeBloc themeBloc;
  late final TextEditingController _textEditingController = TextEditingController(text: '');
  List<Task> _taskList = [];
  List<Task> _filterTaskList = [];
  late StatusFilter filterStatus = StatusFilter.ALL;
  @override
  void initState() {
    themeBloc = context.read<ThemeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initLoadTaskList();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _handleAddTask() {
    setState(() {
      final taskTitle = _textEditingController.text;
      if (taskTitle.isEmpty) {
        CommonUtil.displaySnackbar(
          context: context,
          content: AppString.taskTitleMusNotBeEmpty,
          isErrorMessage: true,
        );
        return;
      }
      _taskList.add(Task(
        title: _textEditingController.text,
        deadline: _currentDeadlineMillis,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      _textEditingController.clear();
      _currentDeadlineMillis = 0;
      _saveTaskList();
      CommonUtil.displaySnackbar(
        context: context,
        content: AppString.addTaskSuccessfully,
        isErrorMessage: false,
      );
      _filterCurrentTaskList(filterStatus);
    });
  }

  _handleRemovedTask(Task task) {
    _taskList.remove(task);
    CommonUtil.displaySnackbar(
      context: context,
      content: AppString.removeTaskSuccessfully,
      isErrorMessage: false,
    );
    _saveTaskList();
    if (_taskList.isEmpty) setState(() {});
  }

  _handleOnStatusChange(Task task, Status status) {
    if (task.status == status) return;
    final indexInTaskList = _taskList.indexWhere((element) => element == task);
    setState(() {
      final newTask = task.copyWith(status: status);
      _filterTaskList = _filterTaskList
          .map(
            (element) => element != task ? element : newTask,
          )
          .toList();
      _taskList[indexInTaskList] = newTask;
      _saveTaskList();
    });
  }

  _handleOnChangePin(Task task) {
    setState(() {
      final newTask = task.copyWith(isPinned: !task.isPinned);
      _filterTaskList = _filterTaskList
          .map(
            (element) => element.copyWith(isPinned: false),
          )
          .toList();
      _taskList = _taskList
          .map(
            (element) => element != task ? element.copyWith(isPinned: false) : newTask,
          )
          .toList();
      if (!task.isPinned) {
        _filterTaskList.remove(task);
        _filterTaskList.insert(0, newTask);
      } else {
        _filterTaskList.removeAt(0);
        _filterTaskList.add(newTask);
        _filterTaskList.sort((task1, task2) => task1.createdAt.compareTo(task2.createdAt));
      }
      _saveTaskList();
    });
  }

  _filterCurrentTaskList(StatusFilter? statusFilter) {
    if (statusFilter == null) return;
    setState(() {
      filterStatus = statusFilter;
      _filterTaskList = _taskList.where((element) {
        if (element.isPinned) return true;
        switch (statusFilter) {
          case StatusFilter.ALL:
            return true;
          case StatusFilter.COMPLETED:
            return element.status == Status.COMPLETED;
          case StatusFilter.UNCOMPLETED:
            return element.status == Status.UNCOMPLETED;
          case StatusFilter.IN_PROGRESS:
            return element.status == Status.IN_PROGRESS;
          case StatusFilter.EXPIRED:
            return element.status == Status.EXPIRED;
        }
      }).toList();
    });
  }

  _saveTaskList() {
    SharedPrefs.saveTaskList(_taskList);
  }

  _initLoadTaskList() {
    SharedPrefs.getTaskList().then((value) {
      setState(() {
        _taskList = value;
        _filterTaskList.addAll(_taskList);
        try {
          final taskPinned = _taskList.firstWhere((element) => element.isPinned);
          _filterTaskList.remove(taskPinned);
          _filterTaskList.insert(0, taskPinned);
        } on StateError {}
      });
    });
  }

  Future<DateTime?> _pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<TimeOfDay?> _pickTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppString.myTasks,
              style: context.textTheme.headlineMedium,
            ),
            elevation: 4,
            centerTitle: false,
            actions: [
              SizedBox(
                height: AppDimens.heightOfSwitch,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch.adaptive(
                    value: state.themeData == ThemeState.darkTheme.themeData,
                    onChanged: (isLight) {
                      if (isLight) {
                        themeBloc.add(ThemeEventToggleToDark());
                      } else {
                        themeBloc.add(ThemeEventToggleToLight());
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp12,
                  vertical: AppSpacing.sp6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: AppString.enterTheTask,
                              prefixIcon: Icon(Icons.edit),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp12),
                        FloatingActionButton(
                          heroTag: 'addTask',
                          onPressed: () {
                            _handleAddTask();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusOfButton),
                          ),
                          elevation: 1,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          child: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            DateTime? selectedDate = await _pickDate();
                            if (selectedDate == null) return;
                            TimeOfDay? selecterTime = await _pickTime();
                            setState(() {
                              if (selecterTime != null) {
                                _currentDeadlineMillis = selectedDate.millisecondsSinceEpoch +
                                    selecterTime.hour * 60 * 60 * 1000 +
                                    selecterTime.minute * 60 * 1000;
                              } else {
                                _currentDeadlineMillis = selectedDate.millisecondsSinceEpoch;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: context.colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(AppDimens.radiusOfButton),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colorScheme.shadow.withOpacity(0.1),
                                    blurRadius: 1,
                                    spreadRadius: 1,
                                    offset: const Offset(2, 2),
                                  )
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sp12,
                                vertical: AppSpacing.sp8,
                              ),
                              child: Text(
                                _currentDeadlineMillis == 0
                                    ? "Choose deadline"
                                    : _currentDeadlineMillis.toDateTime.convertToFormatDate(),
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    DropdownButton(
                      isDense: true,
                      alignment: Alignment.centerLeft,
                      value: filterStatus,
                      underline: const SizedBox(),
                      items: StatusFilter.values
                          .map(
                            (e) => DropdownMenuItem(
                              alignment: Alignment.centerLeft,
                              value: e,
                              child: Text(e.toText()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        _filterCurrentTaskList(value);
                      },
                    )
                  ],
                ),
              ),
              _taskList.isEmpty
                  ? const EmptyTasks()
                  : Expanded(
                      child: DisplayTasks(
                        taskList: _filterTaskList,
                        onRemovedTask: _handleRemovedTask,
                        onChangeStatus: _handleOnStatusChange,
                        onChangePin: _handleOnChangePin,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class DisplayTasks extends StatelessWidget {
  final List<Task> taskList;
  final Function(Task) onRemovedTask;
  final Function(Task, Status) onChangeStatus;
  final Function(Task) onChangePin;
  const DisplayTasks(
      {super.key, required this.taskList, required this.onRemovedTask, required this.onChangeStatus, required this.onChangePin});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp6,
      ),
      itemCount: taskList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = taskList[index];
        return _renderCardTask(item, context, onRemovedTask, (status) {
          onChangeStatus(item, status);
        }, onChangePin);
      },
    );
  }

  Widget _renderCardTask(
    Task item,
    BuildContext context,
    Function(Task) onRemoved,
    Function(Status) onChangeStatus,
    Function(Task) onChangePin,
  ) {
    final remainDay = item.deadline.toDateTime.convertToRemainDays();
    return Dismissible(
      key: ValueKey(item.createdAt),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        onRemoved(item);
        return Future.value(true);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusOfButton),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp12,
            vertical: AppSpacing.sp8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (remainDay < 1 && item.deadline != 0) ...[
                        const SizedBox(width: AppSpacing.sp8),
                        const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                        const SizedBox(width: AppSpacing.sp8),
                      ],
                      InkWell(
                        onTap: () {
                          onChangePin(item);
                        },
                        child: Icon(
                          Icons.push_pin_rounded,
                          color: item.isPinned ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.createdAt.toDateTime.convertToPrettyFormat(),
                    style: context.textTheme.labelSmall?.copyWith(),
                  ),
                  if (item.deadline != 0)
                    Text(
                      "Expired: ${item.deadline.toDateTime.convertToFormatDate()}",
                      style: context.textTheme.labelSmall?.copyWith(),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.deadline != 0 && !item.isExpired()) ...[
                    Text(
                      "Remain: ${item.getRemainingTime()}",
                      style: context.textTheme.labelSmall?.copyWith(),
                    ),
                  ] else
                    const SizedBox(),
                  DropdownButton(
                    isDense: true,
                    value: item.status,
                    underline: const SizedBox(),
                    items: Status.values
                        .map(
                          (e) => DropdownMenuItem(
                            alignment: Alignment.centerLeft,
                            value: e,
                            child: Text(e.toText()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      onChangeStatus(value);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyTasks extends StatelessWidget {
  const EmptyTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return _renderEmptyTasks(context);
  }

  Center _renderEmptyTasks(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            'assets/empty_task_image.png', // Replace with the path to your empty state image
            width: context.widthScreen / 2,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            AppString.noTaskAvailbale,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
