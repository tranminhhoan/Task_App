// Thư viện hỗ trợ StreamController
import 'dart:async';

import 'package:music_app/data/model/song.dart';
import 'package:music_app/data/repository/repository.dart';

// ViewModel đóng vai trò trung gian giữa UI và Data
// Trong mô hình MVVM:
// View (HomePage) -> ViewModel -> Repository -> Source
class MusicAppViewModel {
  // StreamController dùng để phát dữ liệu bài hát tới UI
  // List<Song> : kiểu dữ liệu truyền đi
  // broadcast(): Cho phép nhiều listener cùng lắng nghe stream
  final StreamController<List<Song>> songStream =
  StreamController<List<Song>>.broadcast();

  // Phương thức tải danh sách bài hát
  // Future<void>: Hàm bất đồng bộ (async) Không trả về giá trị
  Future<void> loadSongs() async {
    try {
      // Tạo Repository
      final repository = DefaultRepository();
      // Gọi Repository để lấy dữ liệu
      // Luồng:
      // ViewModel -> Repository -> RemoteDataSource hoặc LocalDataSource
      final songs = await repository.loadData();
      // Đưa dữ liệu vào Stream các Widget đang listen stream sẽ nhận được dữ liệu mới
      songStream.add(songs);
    } catch (e) {
      print("Load songs error: $e");
      // Trả về danh sách rỗng
      songStream.add([]);
    }
  }

  // Giải phóng tài nguyên được gọi trong dispose() của HomePage
  void dispose() {
    // Đóng StreamController
    songStream.close();
  }
}