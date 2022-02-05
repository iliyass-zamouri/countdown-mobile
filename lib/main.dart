import 'dart:developer';
import 'dart:math';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:countdown_death/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Countdown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Countdown(),
    );
  }
}

class Countdown extends StatefulWidget {
  @override
  _CountdownState createState() => _CountdownState();
}

DateTime _deathDate;

class _CountdownState extends State<Countdown> {
  @override
  void initState() {
    super.initState();
    _getDeathTime();
  }

  Future<void> _generateDeathDate() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime newDeathTime;
    do {
      newDeathTime = DateTime(
          Random().nextInt(2100),
          Random().nextInt(10),
          Random().nextInt(200),
          Random().nextInt(1000),
          Random().nextInt(1000));
    } while (newDeathTime?.isBefore(DateTime.now()));

    setState(() {
      _deathDate = newDeathTime;
    });
    await prefs.setString('deathTime', newDeathTime.toString());
  }

  Future<void> _getDeathTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('deathTime') == null) {
      _generateDeathDate();
    } else {
      setState(() {
        _deathDate = DateTime.parse(prefs.getString('deathTime'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _deathDate == null
        ? Material(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.width * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset('assets/satan.jpg')),
                ],
              ),
            ))
        : Material(
            color: Colors.black,
            child: Center(
                child: CountdownTimer(
              widgetBuilder: (context, timeleft) {
                int _days = 0;
                int _yearsLeft = 0;
                double _yearsDouble = 0;
                inspect(timeleft);
                if (timeleft?.days != null) {
                  _yearsDouble = timeleft?.days / 365;
                  _yearsLeft = (_yearsDouble).floor();
                  _days = ((_yearsDouble - _yearsLeft) * 365).floor();
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${_yearsLeft == 0 ? '00' : _yearsLeft < 10 ? '0$_yearsLeft' : _yearsLeft}",
                            style: numberStyle.copyWith(
                                color:
                                    _yearsLeft == 0 ? kPrimary : Colors.white)),
                        Text(
                          'YRS',
                          style: lettersStyle.copyWith(
                              color: _yearsLeft == 0 ? kPrimary : Colors.white),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${_days == 0 ? '00' : _days < 10 ? '0$_days' : _days}",
                            style: numberStyle.copyWith(
                                color: _days == 0 ? kPrimary : Colors.white)),
                        Text(
                          'DYS',
                          style: lettersStyle.copyWith(
                              color: _days == 0 ? kPrimary : Colors.white),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${timeleft?.min == null ? '00' : timeleft?.min < 10 ? '0${timeleft?.min}' : timeleft?.min}",
                            style: numberStyle.copyWith(
                                color: timeleft?.min == null
                                    ? kPrimary
                                    : Colors.white)),
                        Text(
                          'MIN',
                          style: lettersStyle.copyWith(
                              color: timeleft?.min == null
                                  ? kPrimary
                                  : Colors.white),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${timeleft?.sec == null ? '00' : timeleft.sec < 10 ? '0${timeleft?.sec}' : timeleft?.sec}",
                            style: numberStyle.copyWith(
                                color: timeleft?.sec == null
                                    ? kPrimary
                                    : Colors.white)),
                        Text(
                          'SEC',
                          style: lettersStyle.copyWith(
                              color: timeleft?.sec == null
                                  ? kPrimary
                                  : Colors.white),
                        )
                      ],
                    ),
                  ],
                );
              },
              endTime: _deathDate.millisecondsSinceEpoch + 1000 * 30,
            )
                // Text.rich(TextSpan(
                //     children: [Text("00", style: numberStyle), TextSpan()]))

                ));
  }
}

int getDiffYMD(DateTime then) {
  int years = DateTime.now().year - then.year;
  int months = DateTime.now().month - then.month;
  int days = DateTime.now().day - then.day;
  if (months < 0 || (months == 0 && days < 0)) {
    years--;
    months += (days < 0 ? 11 : 12);
  }
  if (days < 0) {
    final monthAgo =
        DateTime(DateTime.now().year, DateTime.now().month - 1, then.day);
    days = DateTime.now().difference(monthAgo).inDays + 1;
  }
  return years;
  // print('$years years $months months $days days');
}
