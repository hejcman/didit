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

/// Update the tag of a memory -
/// delete the memory object from the database and create new one with new tag
void updateMemory(Memory memory) {
  var box = getMemoryBox();
  box.put(memory.key, memory);
  box.flush();
}

/// Delete the memory object from the database.
void deleteMemory(Memory memory) {
  var box = getMemoryBox();
  box.delete(memory.key);
  box.flush();
}

/// Delete any memories which are outdated
void deleteOutdatedMemories() {
  var box = getMemoryBox();
  var outdatedMemories = box.values.where((memory) => memory.isExpired());
  for (Memory memory in outdatedMemories) {
    deleteMemory(memory);
  }
  box.flush();
}

/// Get memories based on their lifetime tag.
///
/// The returned list is reversed if the platform is not iOS, as Android galleries usually
List<Memory> getMemories(LifetimeTag lifetimeTag, {bool reversed = true}) {
  var box = getMemoryBox();

  // If there are no memories, return empty list
  if (box.isEmpty) {
    return <Memory>[];
  }

  // Otherwise, get all the relevant memories
  List<Memory> values = box.values
      .where((memory) => memory.lifetimeTag == lifetimeTag)
      .toList(growable: false);

  if (reversed) {
    return values;
  } else {
    return List<Memory>.from(values.reversed);
  }
}
