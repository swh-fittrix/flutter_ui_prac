import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final now = DateTime.now();

  final startHour = [11, 12, 15];

  final endHour = [12, 14, 16];

  final startMinute = [30, 35, 00];

  final endMinute = [20, 10, 30];

  final title1 = ['DESIGN', 'DAILY', 'WEEKLY'];

  final title2 = ['MEETING', 'PROJECT', 'PLANNING'];

  final subtitle = [
    ['ALEX', 'HELENA', 'NANA'],
    ['ME', 'RICHARD', 'CIRY', '+4'],
    ['DEN', 'NANA', 'MARK'],
  ];

  final color = [
    const Color(0xFFFEF755),
    const Color(0xFF9D6CCE),
    const Color(0xFFBDEE4C),
  ];

  var photo = const NetworkImage(
    'https://www.rd.com/wp-content/uploads/2017/09/01-shutterstock_476340928-Irina-Bg-1024x683'
        '.jpg',
  );
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    photo.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
            (_, __) {
          if (mounted) {
            setState(() {
              isLoaded = true;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayGap = getDays();

    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isLoaded
                      ? CircleAvatar(
                    backgroundImage: photo,
                    radius: 27,
                  )
                      : const CircularProgressIndicator(),
                  const Icon(
                    Icons.add,
                    size: 55,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                '${days[DateTime
                    .now()
                    .weekday]} ${DateTime
                    .now()
                    .day}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(
                height: 15,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: Color(0xFFB32781),
                      ),
                    ),
                    for (var i = 0; i <= dayGap; i++) ...[
                      Text(
                        '${now.day + i}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 47,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      Cards(
                        cardInfo: CardInfo(
                          start: DateTime(
                            now.year,
                            now.month,
                            now.day + i,
                            startHour[i],
                            startMinute[i],
                          ),
                          end: DateTime(
                            now.year,
                            now.month,
                            now.day + i,
                            endHour[i],
                            endMinute[i],
                          ),
                          title1: title1[i],
                          title2: title2[i],
                          subtitles: subtitle[i],
                          color: color[i],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF212121),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  int getDays() {
    print(DateTime(
      now.year,
      now.month + 1,
      0,
    ));
    return DateTime(
      now.year,
      now.month + 1,
    )
        .difference(now)
        .inDays;
  }
}

class Cards extends StatelessWidget {
  final CardInfo cardInfo;

  const Cards({super.key, required this.cardInfo});

  @override
  Widget build(BuildContext context) =>
      Container(
        decoration: BoxDecoration(
          color: cardInfo.color,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        '${cardInfo.start.hour}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '${cardInfo.start.minute}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        width: 0.5,
                        height: 17,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      Text(
                        '${cardInfo.end.hour}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '${cardInfo.end.minute}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${cardInfo.title1}\n${cardInfo.title2}',
                    style: const TextStyle(fontSize: 50, height: 0.8),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 30),
                child: Row(
                  children: [
                    for (var i = 0; i < cardInfo.subtitles.length; i++) ...[
                      Text(
                        cardInfo.subtitles[i],
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class CardInfo {
  final DateTime start;
  final DateTime end;

  final String title1;
  final String title2;

  final List<String> subtitles;

  final Color color;

  const CardInfo({
    required this.start,
    required this.end,
    required this.title1,
    required this.title2,
    required this.subtitles,
    required this.color,
  });
}
