import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'page_manager.dart';
import 'services/service_locator.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children:  [
              CurrentSongTitle(),
              Playlist(),
              AddRemoveSongButtons(),
              AudioProgressBar(),
              AudioControlButtons(),
              SpeedAndSleepTimer(),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeedAndSleepTimer extends StatefulWidget {
  const SpeedAndSleepTimer({Key? key}) : super(key: key);

  @override
  State<SpeedAndSleepTimer> createState() => _SpeedAndSleepTimerState();
}

class _SpeedAndSleepTimerState extends State<SpeedAndSleepTimer> {
  final pageManager = getIt<PageManager>();
  late double temValue;

  @override
  void didChangeDependencies() {
    temValue = pageManager.playBackSpeed.value;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(temValue);

    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return StatefulBuilder(
                  builder: (context, StateSetter setState) {
                    return Column(
                      children: [
                        Slider.adaptive(
                          value: temValue,
                          onChanged: (v) {
                            setState(() {
                              temValue = v;
                            });
                          },
                          min: 0.0,
                          max: 2.0,
                        ),
                        TextButton(
                            onPressed: () {
                              pageManager.setSpeed(temValue);
                              Navigator.of(context).pop();
                            },
                            child: Text("Close"))
                      ],
                    );
                  },
                );
              },
            );
          },
          child: ValueListenableBuilder<double>(
            valueListenable: pageManager.playBackSpeed,
            builder: (_, value, __) {
              String text = value.toStringAsPrecision(2);

             return Column(
                children: [Text('${text}x'), Text("Speed")],
              );
            },
          ),
        )
      ],
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 40)),
        );
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(playlistTitles[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class AddRemoveSongButtons extends StatelessWidget {
  const AddRemoveSongButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: pageManager.add,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: pageManager.remove,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
   AudioControlButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool pre = true;
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:  [
          PreviousSongButton(),
          ProgressUpDown(pre: true,),
          PlayButton(),
          ProgressUpDown(pre: false,),
          NextSongButton(),
        ],
      ),
    );
  }

}

class ProgressUpDown extends StatefulWidget {
  bool pre;
    ProgressUpDown({Key? key, required this.pre}) : super(key: key);

  @override
  State<ProgressUpDown> createState() => _ProgressUpDownState();
}

class _ProgressUpDownState extends State<ProgressUpDown> {
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return ValueListenableBuilder<ProgressBarState>(valueListenable: pageManager.progressNotifier, builder: (_, value, __) {
      return IconButton(iconSize: 50,onPressed: () {
        if(widget.pre){
          pageManager.seek(value.current - Duration(seconds: 10));

        }
        else{
          pageManager.seek(value.current + Duration(seconds: 10));
        }
      }, icon: widget.pre? Column(
        children: [
          Icon(Icons.arrow_circle_left, size: 25,),
          Text("10sec", style: TextStyle(fontSize: 10),)
        ],
      ) : Column(
        children: [
          Icon(Icons.arrow_circle_right, size: 25,),
          Text("10sec", style: TextStyle(fontSize: 10),)
        ],
      ) );
    },);
  }
}



class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}
