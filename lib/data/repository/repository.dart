import '../../data/model/song.dart';
import '../../data/source/source.dart';

// Định nghĩa khuôn mẫu chung cho các Repository
// Mọi lớp triển khai Repository đều phải cài đặt hàm loadData()
abstract interface class Repository {
  // Trả về danh sách bài hát bất đồng bộ (Future)
  Future<List<Song>> loadData();
}

// Lớp DefaultRepository triển khai (implements) interface Repository
class DefaultRepository implements Repository {

  // Tạo đối tượng nguồn dữ liệu cục bộ (Local)
  // Có thể đọc dữ liệu từ file, asset,...
  final _localDataSource = LocalDataSource();
  // Tạo đối tượng nguồn dữ liệu từ xa (Remote)
  // Có thể đọc dữ liệu từ API, Firebase,...
  final _remoteDataSource = RemoteDataSource();

  // Override phương thức loadData() của interface Repository
  @override
  Future<List<Song>> loadData() async {
    // Gọi dữ liệu từ nguồn Remote trước
    // await: chờ dữ liệu trả về
    final remoteSongs = await _remoteDataSource.loadData();

    // Nếu lấy được dữ liệu từ server/API
    if (remoteSongs != null) {
      // Trả về dữ liệu Remote
      return remoteSongs;
    }

    // Nếu Remote không có dữ liệu
    // Thì lấy dữ liệu từ Local
    final localSongs = await _localDataSource.loadData();

    // Nếu Local có dữ liệu
    if (localSongs != null) {
      // Trả về dữ liệu Local
      return localSongs;
    }

    // Nếu cả Remote và Local đều không có dữ liệu
    // Trả về danh sách rỗng
    return [];
  }
}