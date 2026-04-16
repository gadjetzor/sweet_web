import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/service/local_notifications_service.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

class PIReminder extends StatefulWidget {
  @override
  State<PIReminder> createState() => _PIReminderState();
}

class _PIReminderState extends State<PIReminder> {
  String zeroPadInt(int value, {int width = 2}) =>
      value.toString().padLeft(width, '0');

  DateTime? endTime;
  String get endTimePrefsKey => 'PIEndTime';

  _PIReminderState() {
    SharedPreferences.getInstance().then((prefs) {
      final msSinceEpoch = prefs.getInt(endTimePrefsKey);

      if (msSinceEpoch != null) {
        setState(() {
          endTime = DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationService =
        RepositoryProvider.of<LocalNotificationsService>(context);

    final localiseRepo = RepositoryProvider.of<LocalisationRepository>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.public_outlined,
            size: 20,
            color: primaryColor,
          ),
        ),
        title: LocalisedText(
          localiseId: LocalisationStrings.planetaryInteraction,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: _buildSubtitle(),
        onTap: () => setState(() {
          final duration = Duration(hours: 24);
          final date = DateTime.now().add(duration);
          SharedPreferences.getInstance()
              .then(
                (prefs) =>
                    prefs.setInt(endTimePrefsKey, date.millisecondsSinceEpoch),
              );
          endTime = date;
        }),
      ),
    );
  }

  Widget _buildSubtitle() {
    if (endTime == null) {
      return Text(
        '--:--:--\n${StaticLocalisationStrings.tapToRefresh}',
        style: const TextStyle(fontSize: 12),
      );
    }

    return CountdownTimer(
      endTime: endTime?.millisecondsSinceEpoch,
      widgetBuilder: (_, CurrentRemainingTime? time) {
        final hours = time?.hours ?? 0;
        final mins = time?.min ?? 0;
        final sec = time?.sec ?? 0;
        return Text(
          '$hours:${zeroPadInt(mins)}:${zeroPadInt(sec)}\n${StaticLocalisationStrings.tapToRefresh}',
          style: const TextStyle(fontSize: 12),
        );
      },
    );
  }
}
