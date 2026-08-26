import 'package:flutter/services.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';
import 'package:webinar/common/common.dart';
import 'package:youtube_player_embed/controller/video_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_player_embed/youtube_player_embed.dart';

class PodVideoPlayerDev extends StatefulWidget {
  final String type;
  final String url;
  final RouteObserver<ModalRoute<void>> routeObserver;
  final ValueKey key;

  const PodVideoPlayerDev(this.url,this.type, this.routeObserver,this.key,) : super(key: key);

  @override
  State<PodVideoPlayerDev> createState() => _VimeoVideoPlayerState();
}

class _VimeoVideoPlayerState extends State<PodVideoPlayerDev> with RouteAware, AutomaticKeepAliveClientMixin {
  late final PodPlayerController controller;


  VideoController? videoController;

  @override
  void initState() {
    
    if(widget.type == 'vimeo'){
      controller = PodPlayerController(

        playVideoFrom: PlayVideoFrom.vimeo(
          widget.url,
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: true,
          ),
        ),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: true,
          isLooping: false,
          wakelockEnabled: true,
          videoQualityPriority: [360],
        ),
      );

      controller.initialise();

    }else{


      if(widget.type == 'youtube'){
        
      }else{

        controller = PodPlayerController(
          playVideoFrom: widget.type == 'youtube'
              ? PlayVideoFrom.youtube(widget.url)
              : PlayVideoFrom.network(widget.url),

        )..initialise().then((value){
          setState(() {});
        },onError: (e){});
      }
    }

    
    super.initState();
  }

  getYoutubeId(){
    String? id = YoutubePlayerController.convertUrlToId(widget.url);

    if(id == null){
      getYoutubeId();
    }else{
      return id;
    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }


  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    widget.routeObserver.unsubscribe(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {
    // final route = ModalRoute.of(context)?.settings.name;
    try{
      controller.pause();
    }catch(_){}
  } 

  @override
  void didPopNext() {
    try{
      controller.play();
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      key: widget.key,
      padding: padding(horizontal: 0),
      child: ClipRRect(
        borderRadius: borderRadius(),
        child: SizedBox(
          width: getSize().width,
          child: widget.type == 'youtube'
          ? YoutubePlayerEmbed(
              callBackVideoController: (controller) {
                videoController = controller;
                videoController?.playVideo();
              },
              videoId: getYoutubeId(), // 'shorts_video_id' Replace with a YouTube Shorts or normal video ID
              customVideoTitle: "",
              autoPlay: false,
              hidenVideoControls: false,
              mute: false,
              enabledShareButton: false,
              hidenChannelImage: true,
              // aspectRatio: 16 / 9,
              onVideoEnd: () {
                print("video ended");
              },
              onVideoSeek: (currentTime) => print("Seeked to $currentTime seconds"),
              onVideoTimeUpdate: (currentTime) => print("Current time: $currentTime seconds"),
              onVideoStateChange: (state) {
                
              },
            )
          : PodVideoPlayer(controller: controller,),
        ),
      ),
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}