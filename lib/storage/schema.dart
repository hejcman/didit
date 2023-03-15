import 'dart:typed_data';
import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  int tagToInt() {
    switch (this) {
      case LifetimeTag.oneDay:
        return 1;
      case LifetimeTag.sevenDays:
        return 7;
      case LifetimeTag.thirtyDays:
        return 30;
    }
  }

  Color tagColor() {
    switch (this) {
      case LifetimeTag.oneDay:
        return Colors.deepPurple.shade100;
      case LifetimeTag.sevenDays:
        return Colors.deepPurple.shade400;
      case LifetimeTag.thirtyDays:
        return Colors.brown.shade700;
    }
  }

  Widget shortIconWidget({Color? color, Color? textColor}) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
        child: Icon(
          Icons.flag,
          color: color ?? tagColor(),
        ),
      ),
      Text(
        "${tagToInt()}",
        style: TextStyle(color: textColor ?? (color ?? Colors.black)),
      )
    ]);
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
      return "${timeToExpire.inHours} h";
    } else {
      return "${timeToExpire.inDays} d";
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
