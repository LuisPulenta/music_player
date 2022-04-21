import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/src/helpers/helpers.dart';
import 'package:music_player/src/models/audioplayer_model.dart';
import 'package:music_player/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Background(),
        Column(
          children: [
            CustomAppbar(),
            ImagenDiscoDuracion(),
            TituloPlay(),
            Expanded(
              child: Lyrics(),
            )
          ],
        ),
      ],
    ));
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: screenSize.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.center,
            colors: [
              Color(0xff33333E),
              Color(0xff201e28),
            ]),
      ),
    );
  }
}

class Lyrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lyrics = getLyrics();
    return Container(
      child: ListWheelScrollView(
        itemExtent: 42,
        diameterRatio: 1.5,
        physics: BouncingScrollPhysics(),
        children: lyrics
            .map(
              (linea) => Text(
                linea,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 20),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ImagenDiscoDuracion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.only(top: 70),
      child: Row(
        children: [
          ImagenDisco(),
          SizedBox(
            width: 40,
          ),
          BarraProgreso(),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}

class TituloPlay extends StatefulWidget {
  @override
  State<TituloPlay> createState() => _TituloPlayState();
}

class _TituloPlayState extends State<TituloPlay>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool firsTime = true;
  late AnimationController playAnimation;

  final assetAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    playAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    playAnimation.dispose();
    super.dispose();
  }

  void open() {
    final audioPlayerModel =
        Provider.of<AudioPlayerModel>(context, listen: false);

    //! assetAudioPlayer.open('assets/Breaking-Benjamin-Far-Away.mp3');
    assetAudioPlayer.open(Audio('assets/Breaking-Benjamin-Far-Away.mp3'),
        autoStart: true, showNotification: true);

    assetAudioPlayer.currentPosition.listen((duration) {
      audioPlayerModel.current = duration;
    });

    assetAudioPlayer.current.listen((playingAudio) {
      //! audioPlayerModel.songDuration = playingAudio.duration;
      audioPlayerModel.songDuration =
          playingAudio?.audio.duration ?? Duration(seconds: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 50),
        margin: EdgeInsets.only(top: 40),
        child: Row(
          children: [
            Column(
              children: [
                Text('Far Away',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 30)),
                Text('-Breakin Benjamin-',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 15)),
              ],
            ),
            Spacer(),
            FloatingActionButton(
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Color(0xfff8cb51),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: playAnimation,
                ),
                onPressed: () {
                  final audioPlayerModel =
                      Provider.of<AudioPlayerModel>(context, listen: false);
                  if (isPlaying) {
                    playAnimation.reverse();
                    isPlaying = false;

                    audioPlayerModel.controller.stop();
                  } else {
                    playAnimation.forward();
                    isPlaying = true;
                    audioPlayerModel.controller.repeat();
                  }

                  if (firsTime) {
                    this.open();
                    firsTime = false;
                  } else {
                    assetAudioPlayer.playOrPause();
                  }
                })
          ],
        ));
  }
}

class BarraProgreso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(color: Colors.white.withOpacity(0.4));

    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);

    final porcentaje = audioPlayerModel.porcentaje;

    return Column(children: [
      Text('${audioPlayerModel.songTotalDuration}', style: estilo),
      SizedBox(
        height: 10,
      ),
      Stack(
        children: [
          Container(
              width: 3, height: 230, color: Colors.white.withOpacity(0.1)),
          Positioned(
            bottom: 0,
            child: Container(
                width: 3,
                height: 230 * porcentaje,
                color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Text('${audioPlayerModel.currentSecond}', style: estilo),
    ]);
  }
}

class ImagenDisco extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    return Container(
      padding: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SpinPerfect(
              duration: Duration(seconds: 10),
              infinite: true,
              manualTrigger: true,
              controller: (animationController) =>
                  audioPlayerModel.controller = animationController,
              child: Image(
                image: AssetImage('assets/aurora.jpg'),
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Color(0xff1c1c25),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          gradient: LinearGradient(begin: Alignment.topLeft, colors: [
            Color(0xff484750),
            Color(0xff1e1c24),
          ])),
    );
  }
}
