// import 'dart:isolate';
// import 'package:database_service/database_service.dart';
// import 'package:kitchen_module/kitchen_module.dart';
//
// class TaskFailure implements Exception {}
//
// class ConnectionFailure implements Exception {}
//
// class KillIsolate {}
//
// abstract interface class TaskListener {
//   void onEvent(String moduleName, dynamic message,
//       {required bool busy,
//       required DeviceStats deviceStats,
//       required double progress,
//       required int index,
//       UserAction? userAction});
//
//   void onError(Exception error);
// }
//
// class KitchenModule {
//   String? moduleName;
//
//   TaskDataAccess taskDataAccess = TaskDataAccess.instance;
//   RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
//   BaseOperationDataAccess baseOperationDataAccess =
//       BaseOperationDataAccess.instance;
//
//   DeviceStats _deviceStats;
//   bool _busy = false;
//   late SendPort _sendPort;
//   late List<SendPort> _userActionPort;
//   final List<TaskListener> _eventListeners = [];
//
//   ReceivePort _eventPort = ReceivePort();
//
//   TaskPayload? _payload;
//   double _progress = 0.0;
//   int _index = 0;
//   bool _chain = false;
//
//   KitchenModule(this._deviceStats) {
//     moduleName = _deviceStats.moduleName;
//   }
//
//   void updateStats(DeviceStats deviceStats) {
//     _deviceStats = deviceStats;
//     moduleName = _deviceStats.moduleName;
//
//     _busy = _deviceStats.requestId != 'idle';
//
//     _eventListeners.forEach((element) {
//       element.onEvent(_deviceStats.moduleName!, 'Status update',
//           busy: _busy,
//           deviceStats: _deviceStats,
//           progress: _progress,
//           index: _index);
//     });
//   }
//
//   String? getModuleName() {
//     return moduleName;
//   }
//
//   bool isChained() {
//     return _chain;
//   }
//
//   void setChained(bool chain) {
//     _chain = chain;
//     _eventListeners.forEach((element) {
//       element.onEvent(_deviceStats.moduleName!, 'Status update',
//           busy: _busy,
//           deviceStats: _deviceStats,
//           progress: _progress,
//           index: _index);
//     });
//   }
//
//   bool isBusy() {
//     return _busy;
//   }
//
//   TaskPayload? getPayload() {
//     return _payload;
//   }
//
//   double getProgress() {
//     return _progress;
//   }
//
//   int getIndexProgress() {
//     return _index;
//   }
//
//   DeviceStats getDeviceStats() {
//     return _deviceStats;
//   }
//
//   Future<void> initialize(int userActionSize) async {
//     _eventPort = ReceivePort();
//     ReceivePort receivePort = ReceivePort();
//     Isolate.spawn<RunnerModel>(
//         runner, RunnerModel(receivePort.sendPort, userActionSize));
//     List<SendPort> __sendPorts = await receivePort.first;
//     _sendPort = __sendPorts[0];
//     _userActionPort = __sendPorts.getRange(1, __sendPorts.length).toList();
//
//     _eventPort.listen((message) async {
//       if (message == "completed") {
//         _busy = false;
//         _payload!.task.status = Task.COMPLETED;
//         await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
//         _payload = null;
//
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index);
//         });
//
//         if (_chain) {
//           var tasks = await taskDataAccess.search('status = ? and name = ?',
//               whereArgs: [Task.CREATED, _deviceStats.moduleName!]);
//           if (tasks != null) {
//             if (tasks.isNotEmpty) {
//               var task = tasks.first;
//               var recipe = await recipeDataAccess.getById(task.recipeId!);
//               if (recipe != null) {
//                 var operations = await baseOperationDataAccess
//                     .search('recipe_id = ?', whereArgs: [recipe.id!]);
//                 if (operations != null) {
//                   await submitTask(
//                       TaskPayload(recipe, operations, _deviceStats, task));
//                 }
//               }
//             }
//           }
//         } else {
//           receivePort.close();
//           _eventPort.close();
//         }
//       } else if (message == "started") {
//         _busy = true;
//         if (_payload != null) {
//           _payload!.task.status = Task.STARTED;
//           await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
//         }
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index);
//         });
//       } else if (message is TaskProgress) {
//         _progress = message.progress;
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index);
//         });
//       } else if (message is IndexProgress) {
//         _index = message.progress;
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index);
//         });
//       } else if (message is UserAction) {
//         print(message);
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index,
//               userAction: message);
//         });
//       } else if (message is UserResponse) {
//         print(message);
//         _eventListeners.forEach((element) {
//           element.onEvent(_deviceStats.moduleName!, message,
//               busy: _busy,
//               deviceStats: _deviceStats,
//               progress: _progress,
//               index: _index);
//         });
//       } else if (message is Exception) {
//         _payload = null;
//         _busy = false;
//         _eventListeners.forEach((element) {
//           element.onError(message);
//         });
//       } else if (message is KillIsolate) {
//
//         // Isolate.kill(priority: Isolate.immediate);
//       }
//     });
//   }
//
//   void addListeners(TaskListener listener) {
//     _eventListeners.add(listener);
//   }
//
//   void removeListeners(TaskListener listener) {
//     _eventListeners.remove(listener);
//   }
//
//   void submitUserRespond(bool? userRespond, int currentIndex) {
//     print(_userActionPort.length);
//     _userActionPort[currentIndex].send([userRespond]);
//   }
//
//   Future<void> submitTask(TaskPayload p) async {
//     _payload = p;
//
//     if (!_busy) {
//       int userActionSize = 0;
//
//       p.operations.forEach((element) {
//         if (element is UserActionOperation) {
//           userActionSize = userActionSize + 1;
//         }
//       });
//
//       await initialize(userActionSize);
//       print("a task submitted here but not busy");
//       _eventListeners.forEach((element) {
//         element.onEvent(_deviceStats.moduleName!, "Device is not busy",
//             busy: _busy,
//             progress: _progress,
//             deviceStats: _deviceStats,
//             index: _index);
//       });
//       _sendPort.send([_eventPort.sendPort, p]);
//     } else {
//       print("a task submitted here but busy");
//       _eventListeners.forEach((element) {
//         element.onEvent(_deviceStats.moduleName!, "Device is busy",
//             busy: _busy,
//             deviceStats: _deviceStats,
//             progress: _progress,
//             index: _index);
//       });
//     }
//   }
// }
