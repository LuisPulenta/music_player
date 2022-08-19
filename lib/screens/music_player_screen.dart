import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/helpers/helpers.dart';
import 'package:music_player/models/audioplayer_model.dart';
import 'package:music_player/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          Column(
            children: const [
              CustomAppbar(),
              ImagenDiscoDuracion(),
              TituloPlay(),
              Expanded(
                child: Lyrics(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//----------------- Background -----------------

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: screenSize.height * 0.8,
      decoration: const BoxDecoration(
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

//----------------- Lyrics -----------------
class Lyrics extends StatelessWidget {
  const Lyrics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lyrics = getLyrics();
    return ListWheelScrollView(
      itemExtent: 42,
      diameterRatio: 1.5,
      physics: const BouncingScrollPhysics(),
      children: lyrics
          .map(
            (linea) => Text(
              linea,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          )
          .toList(),
    );
  }
}

//----------------- TituloPlay -----------------
class TituloPlay extends StatefulWidget {
  const TituloPlay({
    Key? key,
  }) : super(key: key);

  @override
  State<TituloPlay> createState() => _TituloPlayState();
}

class _TituloPlayState extends State<TituloPlay>
    with SingleTickerProviderStateMixin {
  //----- Variables -----
  bool isPlaying = false;
  bool firsTime = true;
  late AnimationController playAnimation;

  final assetAudioPlayer = AssetsAudioPlayer();

//----- InitState -----
  @override
  void initState() {
    playAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
    assetAudioPlayer.open(Audio('assets/Bohemian Rhapsody.mp3'),
        autoStart: true, showNotification: true);

    assetAudioPlayer.currentPosition.listen((duration) {
      audioPlayerModel.current = duration;
    });

    assetAudioPlayer.current.listen((playingAudio) {
      audioPlayerModel.songDuration =
          playingAudio?.audio.duration ?? const Duration(seconds: 0);
    });
  }

//----- Pantalla -----
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      margin: const EdgeInsets.only(top: 40),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                "Bohemian Rhapsody",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "-Queen-",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          FloatingActionButton(
            elevation: 0,
            highlightElevation: 0,
            backgroundColor: const Color(0xfff8cb51),
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              size: 40,
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
                open();
                firsTime = false;
              } else {
                assetAudioPlayer.playOrPause();
              }
            },
          )
        ],
      ),
    );
  }
}

//----------------- ImagenDiscoDuracion -----------------
class ImagenDiscoDuracion extends StatelessWidget {
  const ImagenDiscoDuracion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      margin: const EdgeInsets.only(top: 70),
      child: Row(
        children: const [
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

//----------------- BarraProgreso -----------------
class BarraProgreso extends StatelessWidget {
  const BarraProgreso({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(color: Colors.white.withOpacity(0.4));
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    final porcentaje = audioPlayerModel.porcentaje;
    return Column(children: [
      Text(audioPlayerModel.songTotalDuration, style: estilo),
      const SizedBox(
        height: 10,
      ),
      Stack(
        children: [
          Container(
            width: 3,
            height: 230,
            color: Colors.white.withOpacity(0.1),
          ),
          Positioned(
            bottom: 0,
            child: Container(
                width: 3,
                height: 230 * porcentaje,
                color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Text(audioPlayerModel.currentSecond, style: estilo),
    ]);
  }
}

//----------------- ImagenDisco -----------------
class ImagenDisco extends StatelessWidget {
  const ImagenDisco({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: const LinearGradient(begin: Alignment.topLeft, colors: [
          Color(0xff484750),
          Color(0xff1e1c24),
        ]),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SpinPerfect(
              duration: Duration(seconds: 5),
              infinite: true,
              manualTrigger: true,
              controller: (animationController) =>
                  audioPlayerModel.controller = animationController,
              child: Image(
                image: AssetImage('assets/aurora.jpg'),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xff1c1c25),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
