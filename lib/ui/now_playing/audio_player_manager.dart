// Package phát nhạc cung cấp phát nhạc, play(), pause(), seek(),...
import 'package:just_audio/just_audio.dart';
// Package hỗ trợ xử lý Stream nâng cao dùng để kết hợp nhiều Stream thành một Stream
import 'package:rxdart/rxdart.dart';

// Lớp quản lý AudioPlayer
// Sử dụng Singleton Pattern
// Toàn bộ ứng dụng chỉ tồn tại 1 AudioPlayer duy nhất
class AudioPlayerManager {
  // Constructor private
  // Không cho phép tạo đối tượng bằng:
  // AudioPlayerManager();
  AudioPlayerManager._internal();

  // Đối tượng duy nhất của lớp
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  // Mọi nơi gọi AudioPlayerManager()
  // đều nhận cùng một instance
  factory AudioPlayerManager() => _instance;
  // Đối tượng phát nhạc
  final player = AudioPlayer();
  // Stream chứa thông tin thời gian bài hát
  // Bao gồm: thời gian hiện tại, thời gian đã buffer(tải trước), tổng thời lượng bài hát
  Stream<DurationState>? durationState;
  // URL bài hát hiện tại
  String songUrl = "";

  // Chuẩn bị dữ liệu cho AudioPlayer
  // isNewSong:
  // true  -> bài hát mới
  // false -> giữ nguyên bài hát hiện tại
  Future<void> prepare({bool isNewSong = false}) async {
    // Kết hợp 2 Stream:
    // 1. vị trí hiện tại
    // 2. trạng thái phát nhạc
    // Tạo thành một Stream duy nhất
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      // Stream vị trí đang phát
      player.positionStream,
      // Stream trạng thái phát nhạc
      player.playbackEventStream,
      // Hàm xử lý dữ liệu nhận được
          (position, playbackEvent) => DurationState(
            // Thời gian hiện tại
        progress: position,
            // Thời gian đã buffer
        buffered: playbackEvent.bufferedPosition,
            // Tổng thời lượng bài hát
        total: playbackEvent.duration,
      ),
    );

    // Nếu là bài hát mới
    // và URL không rỗng
    if (isNewSong && songUrl.isNotEmpty) {
      // Tải bài hát vào player
      await player.setUrl(songUrl);
    }
  }

  // Cập nhật URL bài hát mới
  Future<void> updateSongUrl(String url) async {
    // Lưu URL mới
    songUrl = url;
    // Chuẩn bị phát bài hát mới
    await prepare(isNewSong: true);
  }

  // Giải phóng tài nguyên AudioPlayer
  void dispose() {
    // Hủy player
    player.dispose();
  }
}

// Lớp lưu thông tin thời lượng bài hát
class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}