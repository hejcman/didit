import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'schema.g.dart';

@HiveType(typeId: 0)
enum LifetimeTag {
  @HiveField(0)
  oneDay,
  @HiveField(1)
  sevenDays,
  @HiveField(2)
  thirtyDays,
}

const lifetimeTags = <LifetimeTag, String>{
  LifetimeTag.oneDay: "1 Day",
  LifetimeTag.sevenDays: "7 Days",
  LifetimeTag.thirtyDays: "30 Days",
};

extension LifetimeTagExtension on LifetimeTag {

  /// Convert a lifetime tag to Duration
  Duration toDuration() {
    switch (this) {
      case LifetimeTag.oneDay:
        return const Duration(days: 1);
      case LifetimeTag.sevenDays:
        return const Duration(days: 7);
      case LifetimeTag.thirtyDays:
        return const Duration(days: 30);
    }
  }
}

@HiveType(typeId: 1)
class Memory extends HiveObject {
  /// The time the photo was created. This should not change once created.
  @HiveField(0)
  DateTime created;

  /// Storing the image blob in the database.
  @HiveField(1)
  Uint8List pictureBytes;

  /// The tag regarding the lifetime of the memory.
  /// This can be updated by the user.
  @HiveField(2)
  LifetimeTag lifetimeTag;

  /// Constructor
  Memory(this.created, this.pictureBytes, this.lifetimeTag);

  /// Return the DateTime when the Memory will be considered expired
  DateTime getExpiration() {
    return created.add(lifetimeTag.toDuration());
  }

  String getTimeToExpire() {
    Duration timeToExpire =
        created.add(lifetimeTag.toDuration()).difference(DateTime.now());
    if (timeToExpire.inDays == 0) {
      return "${timeToExpire.inHours} hours";
    } else {
      return "${timeToExpire.inDays} days";
    }
  }
  
  /// Check if the current Memory is expired.
  bool isExpired() {
    DateTime expirationTime = getExpiration();
    DateTime currentTime = DateTime.now();

    return currentTime.isAfter(expirationTime) ? true : false;
  }
}

/// Generate adapters to convert Dart classes to ones stored in the Hive DB.
void generateAdapters() {
  Hive.registerAdapter<LifetimeTag>(LifetimeTagAdapter());
  Hive.registerAdapter<Memory>(MemoryAdapter());
}
