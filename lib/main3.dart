import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var roundCount = 0;
  final roundMax = 4;

  var goalCount = 0;
  final goalMax = 12;

  var watchMinutes = 25;
  var watchSeconds = 0;

  var equalBlink = true;

  var isPlaying = false;

  var onBreakTime = false;

  final timerMinutes = [
    15,
    20,
    25,
    30,
    35,
  ];
  final controller = PageController(initialPage: 2, viewportFraction: 0.25);
  var selectIndex = 2;

  final themeColor = const Color(0xFFE64E3F);

  late var buttonIndex = 0;
  late final buttonIcons = [
    [
      buttonWidget(
        iconData: Icons.play_arrow_rounded,
        buttonClicked: buttonClicked,
        timerTrigger: startTimer,
      ),
    ],
    [
      buttonWidget(
        iconData: Icons.pause_rounded,
        buttonClicked: buttonClicked,
        timerTrigger: pauseTimer,
      ),
      buttonWidget(
        iconData: Icons.replay_rounded,
        buttonClicked: buttonClicked,
        timerTrigger: resetTimer,
      ),
    ],
  ];

  Timer? timer;

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POMOTIMER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      if (onBreakTime)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'BREAK TIME!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: watchCardWidget(
                          watchTime: watchMinutes,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            ':',
                            style: TextStyle(
                              color: equalBlink
                                  ? const Color(0xFFF1938B)
                                  : const Color(0xFFE64E3F),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: watchCardWidget(
                          watchTime: watchSeconds,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.white,
                          ],
                          stops: [
                            0.0,
                            0.2,
                            0.8,
                            1.0,
                          ],
                        ).createShader(bounds),
                    blendMode: BlendMode.dstOut,
                    child: PageView(
                      controller: controller,
                      physics: isPlaying
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      onPageChanged: (value) =>
                          setState(() {
                            selectIndex = value;
                            watchMinutes = timerMinutes[value];
                            watchSeconds = 0;
                          }),
                      children: [
                        for (var second in timerMinutes)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 28, horizontal: 10),
                            child: timeCardWidget(
                              second: second,
                              selected: selectIndex ==
                                  timerMinutes.indexOf(second),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AbsorbPointer(
                    absorbing: onBreakTime,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: buttonIcons[buttonIndex],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cycleWidget(
                        count: roundCount,
                        max: roundMax,
                        type: 'ROUND',
                      ),
                      cycleWidget(
                        count: goalCount,
                        max: goalMax,
                        type: 'GOAL',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: themeColor,
        ),
        debugShowCheckedModeBanner: false,
      );

  void buttonClicked() {
    isPlaying = buttonIndex == 0;

    setState(() {
      buttonIndex = buttonIndex == 0 ? 1 : 0;
    });
  }

  void startTimer(BuildContext localContext) {
    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (watchSeconds == 0) {
          if (watchMinutes == 0) {
            if (onBreakTime) {
              onBreakTime = false;
              watchMinutes = timerMinutes[selectIndex];
              buttonClicked();
              pauseTimer(localContext);
            } else {
              onBreakTime = true;
              watchMinutes = 5;
              roundCount++;
            }

            if (roundCount == roundMax) {
              goalCount++;
              if (goalCount == goalMax) {
                pauseTimer(localContext);
                showDialog(
                  context: localContext,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text(
                            'Congratulations! You have completed your goal!'),
                        actions: [
                          TextButton(
                            onPressed: () => SystemNavigator.pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
              roundCount = 0;
            }
          } else {
            watchMinutes--;
            watchSeconds = 59;
          }
          setState(() {});
        } else {
          setState(() {
            watchSeconds--;
          });
        }
        equalBlink = !equalBlink;
      },
    );
  }

  void resetTimer(BuildContext localContext) {
    setState(() {
      watchMinutes = timerMinutes[selectIndex];
      watchSeconds = 0;
      timer?.cancel();
      startTimer(localContext);
    });
  }

  void pauseTimer(BuildContext localContext) {
    timer?.cancel();
  }
}

class watchCardWidget extends StatelessWidget {
  final int watchTime;

  const watchCardWidget({super.key, required this.watchTime});

  @override
  Widget build(BuildContext context) =>
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.transparent,
            width: double.infinity,
          ),
          for (var i = 1; i <= 2; i++)
            Positioned(
              top: i * 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    255,
                    255,
                    255,
                    i * 0.3,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                width: 110 + i * 12,
                height: 170,
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            width: 160,
            height: 170,
            child: Center(
              child: Text(
                watchTime.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFFE64E3F),
                  fontSize: 85,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
}

class timeCardWidget extends StatelessWidget {
  final int second;
  final bool selected;

  const timeCardWidget({
    super.key,
    required this.second,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) =>
      Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          border: const Border.fromBorderSide(
            BorderSide(color: Colors.white, width: 2),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            '$second',
            style: TextStyle(
              color: selected ? const Color(0xFFE64E3F) : Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

class buttonWidget extends StatefulWidget {
  final IconData iconData;
  final Function buttonClicked;
  final Function timerTrigger;

  buttonWidget({
    super.key,
    required this.iconData,
    required this.buttonClicked,
    required this.timerTrigger,
  });

  @override
  State<buttonWidget> createState() => _buttonWidgetState();
}

class _buttonWidgetState extends State<buttonWidget> {
  var circleColor = const Color.fromRGBO(0, 0, 0, 0.2);
  var IconColor = Colors.white;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
        onTapDown: (_) =>
            setState(() {
              circleColor = const Color.fromRGBO(255, 255, 255, 0.2);
              IconColor = Colors.black;
            }),
        onTapUp: (__) =>
            setState(() {
              setNormal();

              widget.timerTrigger(context);
              if (widget.iconData == Icons.play_arrow_rounded) {
                widget.buttonClicked();
              } else if (widget.iconData == Icons.pause_rounded) {
                widget.buttonClicked();
              } else {
                print('replay');
              }
            }),
        onTapCancel: () => setState(() => setNormal()),
        child: Container(
          decoration: BoxDecoration(
            color: circleColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          width: 90,
          height: 90,
          child: Icon(
            widget.iconData,
            size: 45,
            color: IconColor,
          ),
        ),
      );

  void setNormal() {
    circleColor = const Color.fromRGBO(
      0,
      0,
      0,
      0.2,
    );
    IconColor = Colors.white;
  }
}

class cycleWidget extends StatelessWidget {
  final int count;
  final int max;
  final String type;

  const cycleWidget({
    super.key,
    required this.count,
    required this.max,
    required this.type,
  });

  @override
  Widget build(BuildContext context) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count/$max',
            style: const TextStyle(
              color: Color(0xFFF4A69F),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            type,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
