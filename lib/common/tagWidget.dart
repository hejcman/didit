import 'package:didit/common/platformization.dart';
import 'package:flutter/material.dart';

// Globals
import '../globals.dart' as globals;

// Storage
import '../storage/schema.dart';

//Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class tagWidget extends StatelessWidget {
  const tagWidget({super.key, required this.tag});

  final LifetimeTag tag;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
        child: Icon(getFlagIcon(), color: tag.tagColor()),
      ),
      Text(AppLocalizations.of(context)!.nDays(tag.tagToInt()),
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground))
    ]);
  }
}
