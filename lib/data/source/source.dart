// Thư viện dùng để mã hóa và giải mã JSON
import 'dart:convert';
// Thư viện hỗ trợ đọc file trong thư mục assets của Flutter
import 'package:flutter/services.dart';
// Thư viện HTTP dùng để gọi API
import 'package:http/http.dart' as http;

import '../model/song.dart';


abstract interface class DataSource {
  // Phương thức tải dữ liệu bài hát
  // Trả về danh sách Song hoặc null
  Future<List<Song>?> loadData();
}
// lấy dữ liệu từ Internet/API
class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // URL chứa dữ liệu JSON bài hát
    const url = 'https://thantrieu.com/resources/braniumapis/songs.json';
    // Chuyển String URL thành đối tượng Uri
    final uri = Uri.parse(url);
    // Gửi HTTP GET request đến server
    final response = await http.get(uri);
    // Kiểm tra server trả về thành công hay không
    if (response.statusCode == 200) {
      // Chuyển dữ liệu bytes sang UTF8
      // Tránh lỗi tiếng Việt bị lỗi font
      final bodyContent = utf8.decode(response.bodyBytes);
      // Chuyển JSON String thành Map
      final songWrapper = jsonDecode(bodyContent) as Map<String, dynamic>;
      // Lấy danh sách bài hát từ key "songs"
      final songList = songWrapper['songs'] as List;
      // Chuyển từng phần tử JSON thành đối tượng Song
      return songList
          .map((song) => Song.fromJson(song as Map<String, dynamic>))
          .toList();
    } else {
      // Nếu API lỗi thì trả về null
      return null;
    }
  }
}

// lấy dữ liệu từ file local trong assets
class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // Đọc file songs.json trong thư mục assets
    final response = await rootBundle.loadString('assets/songs.json');
    // Chuyển JSON String thành Map
    final jsonBody = jsonDecode(response) as Map<String, dynamic>;
    // Lấy danh sách bài hát trong key "songs"
    final songList = jsonBody['songs'] as List;
    // Chuyển từng JSON object thành đối tượng Song
    return songList
        .map((song) => Song.fromJson(song as Map<String, dynamic>))
        .toList();
  }
}