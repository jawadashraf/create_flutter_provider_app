import 'package:flutter/material.dart';
import 'package:noteapp/app_localizations.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:provider/provider.dart';

enum MasjidsActions { toggleAllComplete, clearCompleted }

class MasjidsExtraActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase = Provider.of(context);

    return PopupMenuButton<MasjidsActions>(
      icon: Icon(Icons.more_horiz),
      onSelected: (MasjidsActions result) {
        switch (result) {
          case MasjidsActions.toggleAllComplete:
            // firestoreDatabase.setAllMasjidComplete();
            break;
          case MasjidsActions.clearCompleted:
          // firestoreDatabase.deleteAllMasjidWithComplete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MasjidsActions>>[
        PopupMenuItem<MasjidsActions>(
          value: MasjidsActions.toggleAllComplete,
          child: Text(AppLocalizations.of(context)
              .translate("todosPopUpToggleAllComplete")),
        ),
        PopupMenuItem<MasjidsActions>(
          value: MasjidsActions.clearCompleted,
          child: Text(AppLocalizations.of(context)
              .translate("todosPopUpToggleClearCompleted")),
        ),
      ],
    );
  }
}
