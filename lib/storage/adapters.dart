import 'dart:developer';

import '../globals.dart' as globals;
import 'schema.dart';

/// Add the memory object to the database.
void createMemory(Memory memory) {
  log("Creating a new memory.");
  globals.box.add(memory);
  globals.box.flush();
}

/// Update the tag of a memory -
/// delete the memory object from the database and create new one with new tag
void updateMemory(Memory memory) {
  log("Updating an existing memory with key ${memory.key}.");
  globals.box.put(memory.key, memory);
  globals.box.flush();
}

/// Delete the memory object from the database.
void deleteMemory(Memory memory) {
  log("Deleting a memory with key ${memory.key}.");
  globals.box.delete(memory.key);
  globals.box.flush();
}

/// Delete any memories which are outdated
void deleteOutdatedMemories() {
  log("Deleting all outdated memories.");
  var outdatedMemories = globals.box.values.where((memory) => memory.isExpired());
  log("Found ${outdatedMemories.length} outdated memories.");
  for (Memory memory in outdatedMemories) {
    deleteMemory(memory);
  }
  globals.box.flush();
}

/// Get memories based on their lifetime tag.
///
/// The returned list is reversed if the platform is not iOS, as Android galleries usually
List<Memory> getMemories(LifetimeTag lifetimeTag, {bool reversed = true}) {
  log("Getting all memories with tag $lifetimeTag.");

  // If there are no memories, return empty list
  if (globals.box.isEmpty) {
    return <Memory>[];
  }

  // Otherwise, get all the relevant memories
  List<Memory> values = globals.box.values
      .where((memory) => memory.lifetimeTag == lifetimeTag)
      .toList(growable: false);

  log("Found ${values.length} memories with the given lifetimeTag.");

  if (reversed) {
    return values;
  } else {
    return List<Memory>.from(values.reversed);
  }
}
