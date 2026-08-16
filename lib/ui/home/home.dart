import 'package:flutter/cupertino.dart'; // giao dien ios
import 'package:flutter/material.dart'; // giao dien android
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../now_playing/playing.dart';

// StatelessWidget vì không có dữ liệu thay đổi
class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicHomePage();
  }
}

// Màn hình chính chứa các Tab
// StatefulWidget vì cần thay đổi tab đang được chọn
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

// State quản lý trạng thái của MusicHomePage
class _MusicHomePageState extends State<MusicHomePage> {
  // Danh sách các tab trong ứng dụng
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Giao diện kiểu iOS
    return CupertinoPageScaffold(
      // Thanh tiêu đề trên cùng
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music App'),
      ),
      // Widget quản lý các tab
      child: CupertinoTabScaffold(
        // Thanh menu dưới
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          // Danh sách các nút tab
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        // Hàm được gọi khi chọn tab
        tabBuilder: (BuildContext context, int index) {
          // Hiển thị màn hình tương ứng
          return _tabs[index];
        },
      ),
    );
  }
}

// Widget trung gian cho tab Home
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về trang Home thực tế
    return const HomeTabPage();
  }
}

// Trang Home chính
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

// State của HomeTabPage
class _HomeTabPageState extends State<HomeTabPage> {
  // danh sách bài hát
  List<Song> songs = [];
  // ViewModel dùng để xử lý dữ liệu
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ViewModel
    _viewModel = MusicAppViewModel();
    // lắng nghe sự thay doi cua du lieu
    observeData();
    // Bắt đầu tải danh sách bài hát
    _viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nd man hình
      body: getBody(),
    );
  }

  @override
  void dispose() {
    // Giải phóng StreamController
    _viewModel.dispose();
    super.dispose();
  }

  // Quyết định hiển thị Loading hay ListView
  Widget getBody() {

    // Chưa có dữ liệu
    if (songs.isEmpty) {
      return getProgressBar();
    }
    // Có dữ liệu
    return getListView();
  }

  // Hiển thị vòng quay loading
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Hiển thị danh sách bài hát
  ListView getListView() {
    return ListView.separated(
      // Tạo từng item
      itemBuilder: (context, position) {
        return getRow(position);
      },
      // Đường kẻ giữa các item
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      // Tổng số item
      itemCount: songs.length,
    );
  }

  // Tạo một dòng bài hát
  Widget getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  // Lắng nghe dữ liệu từ ViewModel
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      // Kiểm tra widget còn tồn tại không
      if (!mounted) return;
      // Cập nhật giao diện
      setState(() {
        songs = songList;
      });
    });
  }

  // Hiển thị BottomSheet
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // widget bo tròn các góc
        return ClipRRect(
          // Bo góc phía trên
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Container(
            height: 400,
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Model Bottom Sheet'),
                  ElevatedButton(
                    // Đóng BottomSheet
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Bottom Sheet'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Chuyển sang màn hình phát nhạc
  void navigate(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return NowPlaying(
            // Danh sách bài hát
            songs: songs,
            // Bài hát được chọn
            playingSong: song,
          );
        },
      ),
    );
  }
}

// Widget hiển thị một bài hát
class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  // Tham chiếu tới HomePage
  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Khoảng cách nội dung
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      // Hình ảnh bài hát
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FadeInImage.assetNetwork(
          // Ảnh tạm khi đang tải
          placeholder: 'assets/img.png',
          // Ảnh từ internet
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            // Nếu lỗi tải ảnh
            return Image.asset(
              'assets/img.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      // Tên bài hát
      title: Text(song.title),
      // Tên ca sĩ
      subtitle: Text(song.artist),
      // Nút 3 chấm
      trailing: IconButton(
        onPressed: () {
          // Hiện BottomSheet
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
      ),
      // Nhấn vào bài hát
      onTap: () {
        // Chuyển sang màn hình phát nhạc
        parent.navigate(song);
      },
    );
  }
}