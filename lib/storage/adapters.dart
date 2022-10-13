import 'package:hive/hive.dart';

import '../globals.dart';
import 'schema.dart';

/// Get a database instance that you can then operate with.
Box<Memory> getMemoryBox() {
  return Hive.box<Memory>(Globals.dbName);
}

/// Add the memory object to the database.
void createMemory(Memory memory) {
  var box = getMemoryBox();
  box.add(memory);
  box.flush();
}

/// Delete the memory object from the database.
void deleteMemory(Memory memory) {
  var box = getMemoryBox();
  box.delete(memory);
  box.flush();
}
