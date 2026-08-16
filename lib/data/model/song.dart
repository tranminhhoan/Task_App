//File này là lớp Model đại diện cho thực thể bài hát, chứa các thuộc tính của bài hát và các phương thức hỗ trợ chuyển đổi dữ liệu giữa đối tượng Dart và JSON.
// Lớp Song dùng để mô tả một bài hát trong ứng dụng
class Song{
  // các thuộc tính lưu  tên, album,....
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;

  //Constructor có tham số
  // required bắt buộc khi tạo đối tượng Song phải truyền đầy đủ các giá trị
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration});

  // Method chuyển đối tượng Song thành Map
  // Thường dùng khi lưu dữ liệu xuống JSON, API, Firebase,...
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'artist': artist,
      'source': source,
      'image': image,
      'duration': duration,
    };
  }

  // Dùng để tạo đối tượng Song từ dữ liệu JSON hoặc Map
  // đọc dữ liệu từ API hoặc file JSON
  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      album: map['album'] as String,
      artist: map['artist'] as String,
      source: map['source'] as String,
      image: map['image'] as String,
      duration: map['duration'] as int,
    );
  }

  // Cho phép so sánh 2 đối tượng Song
  // Hai bài hát được xem là giống nhau nếu có cùng id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Song && runtimeType == other.runtimeType && id == other.id;

  // Hỗ trợ cho việc so sánh đối tượng trong Set, Map,...
  // hashCode phải tương ứng với điều kiện so sánh ở trên
  @override
  int get hashCode => id.hashCode;

  // in thông tin đối tượng ra màn hình dễ đọc hơn
  // dùng để debug hoặc kiểm tra dữ liệu
  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration}';
  }


}