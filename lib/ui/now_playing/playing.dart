// Hỗ trợ StreamSubscription
import 'dart:async';
// Hỗ trợ sinh số ngẫu nhiên
import 'dart:math';
// Widget thanh tiến trình bài hát
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Package phát nhạc
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({
    super.key,
    // Bài hát được chọn
    required this.playingSong,
    // Danh sách tất cả bài hát
    required this.songs,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    // Chuyển dữ liệu sang NowPlayingPage
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

// Màn hình phát nhạc chính
class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

// State quản lý giao diện phát nhạc
// SingleTickerProviderStateMixin dùng cho AnimationController
class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  // Điều khiển animation xoay ảnh album
  late AnimationController _imageAnimController;
  // Singleton quản lý AudioPlayer
  late AudioPlayerManager _audioPlayerManager;
  // Vị trí bài hát hiện tại trong danh sách
  late int _selectedItemIndex;
  // Bài hát hiện tại đang phát
  late Song _song;

  // Trạng thái tron bai
  bool _isShuffle = false;
  // trang thai lap lai
  late LoopMode _loopMode;
  // Subscription lắng nghe trạng thái player
  StreamSubscription<ProcessingState>? _processingSubscription;

  @override
  void initState() {
    super.initState();
    // Lưu bài hát được truyền từ HomePage
    _song = widget.playingSong;
    // Tìm vị trí bài hát trong danh sách
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    // Mặc định không lặp
    _loopMode = LoopMode.off;
    // Tạo AnimationController vsync giúp tối ưu hiệu năng
    // duration: 25 giây quay hết 1 vòng
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
    // Lấy Singleton AudioPlayerManager
    _audioPlayerManager = AudioPlayerManager();
    // Nếu URL bài hát khác bài hiện tại
    // thì tải bài hát mới
    if (_audioPlayerManager.songUrl != _song.source) {
      _audioPlayerManager.updateSongUrl(_song.source);
    } else {
      // Nếu đã là bài hát hiện tại
      // chỉ cần chuẩn bị lại dữ liệu
      _audioPlayerManager.prepare();
    }
    // Lắng nghe trạng thái AudioPlayer
    _processingSubscription =
        _audioPlayerManager.player.processingStateStream.listen((state) {
          // Khi bài hát phát xong
          if (state == ProcessingState.completed) {
            // Nếu lap 1 lan
            if (_loopMode == LoopMode.one) {
              // Quay về đầu bài hát
              _audioPlayerManager.player.seek(Duration.zero);
              // Phát lại
              _audioPlayerManager.player.play();
            } else {
              // Chuyển bài tiếp theo
              _setNextSong();
            }
          }
        });
  }

  @override
  void dispose() {
    // Giải phóng AudioPlayer
    // Tránh chiếm bộ nhớ khi thoát màn hình
    _audioPlayerManager.dispose(); //khi giải phóng bài hát không được phát ở màn hình khác nữa
    // Hủy lắng nghe ProcessingState Stream
    // Tránh rò rỉ bộ nhớ
    _processingSubscription?.cancel();
    // Giải phóng AnimationController
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình hiện tại
    final screenWidth = MediaQuery.of(context).size.width;
    // Khoảng cách lề trái + phải
    const delta = 64;
    // Tính bán kính bo tròn ảnh album để tạo hình tròn hoàn chỉnh
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      // Thanh tiêu đề phía trên
      navigationBar: CupertinoNavigationBar(
        // Tiêu đề màn hình
        middle: const Text('Now Playing'),
        // Nút 3 chấm bên phải
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            // Canh đều các thành phần theo chiều dọc
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 56),
              Text(_song.album),
              const Text('_ ___ _'),
              const SizedBox(height: 8),
              // Widget xoay ảnh album
              RotationTransition(
                // Animation từ 0 -> 1 vòng
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageAnimController),
                child: ClipRRect(
                  // Bo tròn ảnh album
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes_256.png',
                    image: _song.image,
                    // Kích thước ảnh
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes_256.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              // Khu vực thông tin bài hát
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: SizedBox(
                  child: Row(
                    // Căn đều theo chiều ngang
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            _song.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              // Thanh tiến trình bài hát
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
                child: _progressBar(),
              ),
              // Các nút điều khiển nhạc
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 8,
                  right: 24,
                  bottom: 8,
                ),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
// Tạo hàng chứa các nút điều khiển nhạc
  Widget _mediaButtons() {
    return Row(
      // Canh đều các nút
    mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MediaButtonControl(
          // Hàm bật/tắt Shuffle
          function: _setShuffle,
          icon: Icons.shuffle,
          color: _getShuffleColor(),
          size: 24,
        ),
        MediaButtonControl(
          // Chuyển bài trước
          function: _setPrevSong,
          icon: Icons.skip_previous,
          color: Colors.deepPurple,
          size: 36,
        ),
        // Nút Play / Pause / Replay
        _playButton(),
        // Nút Next
        MediaButtonControl(
          function: _setNextSong,
          icon: Icons.skip_next,
          color: Colors.deepPurple,
          size: 36,
        ),
        // Nút Repeat
        MediaButtonControl(
          function: _setupRepeatOption,
          icon: _repeatingIcon(),
          color: _getRepeatingIconColor(),
          size: 24,
        ),
      ],
    );
  }

  // Hiển thị thanh tiến trình bài hát
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          // Kéo thanh để tua bài hát
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withValues(alpha: 0.3),
          progressBarColor: Colors.green,
          bufferedBarColor: Colors.grey.withValues(alpha: 0.3),
          thumbColor: Colors.deepPurple,
          thumbGlowColor: Colors.grey.withValues(alpha: 0.3),
          thumbRadius: 10.0,
        );
      },
    );
  }

  // Hiển thị nút Play / Pause / Replay
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      // Stream trạng thái AudioPlayer
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        // Trạng thái hiện tại
        final playState = snapshot.data;
        // Trạng thái xử lý
        final processingState = playState?.processingState;
        // Đang phát hay không
        final playing = playState?.playing;
        // Đang tải hoặc buffer
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            // Hiển thị loading
            child: const CircularProgressIndicator(),
          );
          // Chưa phát nhạc
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              // Phát nhạc
              _audioPlayerManager.player.play();
              // Cho ảnh album quay
              _playRotationAnim();
            },
            icon: Icons.play_arrow,
            color: null,
            size: 48,
          );
          // Đang phát
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              // Tạm dừng
              _audioPlayerManager.player.pause();
              // Dừng animation quay
              _pauseRotationAnim();
            },
            icon: Icons.pause,
            color: null,
            size: 48,
          );
          // Đã phát hết bài hát
        } else {
          return MediaButtonControl(
            function: () {
              // Quay về đầu bài hát
              _audioPlayerManager.player.seek(Duration.zero);
              // Phát lại
              _audioPlayerManager.player.play();
              // Reset animation
              _resetRotationAnim();
              // Cho quay lại
              _playRotationAnim();
            },
            icon: Icons.replay,
            color: null,
            size: 48,
          );
        }
      },
    );
  }

  // Bật/Tắt chế độ phát ngẫu nhiên
  void _setShuffle() {
    // Đảo trạng thái hiện tại
    // false -> true
    // true -> false
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }
  // Xác định màu nút Shuffle
  Color? _getShuffleColor() {
    // Nếu đang bật Shuffle Colors.deepPurple
    // Nếu tắt Shuffle Colors.grey
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  // Chuyển sang bài hát tiếp theo
  void _setNextSong() {
    if (widget.songs.isEmpty) return;
    // Nếu bật Shuffle
    if (_isShuffle) {
      // Chọn ngẫu nhiên vị trí bài hát
      final random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      // Bài tiếp theo
      _selectedItemIndex = (_selectedItemIndex + 1) % widget.songs.length;
    }

    // Lấy bài hát mới
    final nextSong = widget.songs[_selectedItemIndex];
    // Đổi URL bài hát
    _audioPlayerManager.updateSongUrl(nextSong.source);
    // Phát ngay
    _audioPlayerManager.player.play();
    // Reset animation quay
    _resetRotationAnim();
    // Quay lại từ đầu
    _playRotationAnim();

    // Cập nhật giao diện
    if (!mounted) return;
    setState(() {
      _song = nextSong;
    });
  }

  // Chuyển về bài trước
  void _setPrevSong() {
    if (widget.songs.isEmpty) return;
    // Nếu bật trộn bài
    if (_isShuffle) {
      // Chọn bài ngẫu nhiên
      final random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      // Lùi về bài trước
      _selectedItemIndex =
          (_selectedItemIndex - 1 + widget.songs.length) % widget.songs.length;
    }
    // Lấy bài hát mới
    final prevSong = widget.songs[_selectedItemIndex];
    // Đổi URL
    _audioPlayerManager.updateSongUrl(prevSong.source);
    // Phát bài hát
    _audioPlayerManager.player.play();
    // Reset animation
    _resetRotationAnim();
    // Quay từ đầu
    _playRotationAnim();
    // Cập nhật giao diện
    setState(() {
      _song = prevSong;
    });
  }

  // Đổi chế độ Repeat
  void _setupRepeatOption() {
    // OFF -> ONE
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } // ONE -> ALL
    else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } // ALL -> OFF
     else {
      _loopMode = LoopMode.off;
    }
    // Cập nhật vào AudioPlayer
    _audioPlayerManager.player.setLoopMode(_loopMode);
    setState(() {});
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }
  // Cho ảnh album quay
  void _playRotationAnim() {
    if (!_imageAnimController.isAnimating) {
      _imageAnimController.repeat();
    }
  }
// Dừng quay ảnh album
  void _pauseRotationAnim() {
    if (_imageAnimController.isAnimating) {
      _imageAnimController.stop();
    }
  }
// Đưa ảnh về vị trí ban đầu
  void _resetRotationAnim() {
    _imageAnimController.reset();
  }
}

// Widget dùng để tạo các nút điều khiển nhạc
// Được tái sử dụng cho:
// - Play
// - Pause
// - Replay
// - Next
// - Previous
// - Shuffle
// - Repeat
class MediaButtonControl extends StatefulWidget {
  // Constructor
  const MediaButtonControl({
    super.key,
    // Hàm sẽ được gọi khi nhấn nút
    required this.function,
    // Icon hiển thị trên nút
    required this.icon,
    // Màu của icon
    required this.color,
    // Kích thước icon
    required this.size,
  });

  // Callback Function
  // Ví dụ:
  // _setNextSong()
  // _setPrevSong()
  // player.play()
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    // Trả về IconButton
    return IconButton(
      // Hàm được gọi khi người dùng nhấn
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      // Nếu có màu truyền vào thì dùng màu đó
      // Nếu không sẽ lấy màu chính của Theme
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
