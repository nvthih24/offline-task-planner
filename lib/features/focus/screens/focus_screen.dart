import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/constants/app_colors.dart';

import '../widgets/custom_circle_button.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  // CẤU HÌNH THỜI GIAN
  int selectedMinutes = 25; // Mặc định 25 phút
  late int remainingSeconds;

  Timer? _timer;
  bool isRunning = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedSound = 'none';

  final Map<String, String> _soundPaths = {
    'rain': 'sounds/tieng_troi_mua_lon-www_tiengdong_com.mp3',
    'lofi': 'sounds/lofi-chill-372954.mp3',
    'chill': 'sounds/chill-lofi-347217.mp3',
  };

  @override
  void initState() {
    super.initState();
    remainingSeconds = selectedMinutes * 60;
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _playMusic() async {
    if (_selectedSound == 'none') return;
    try {
      // Set volume vừa phải (50%) để không át tiếng suy nghĩ
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play(AssetSource(_soundPaths[_selectedSound]!));
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");
    }
  }

  Future<void> _pauseMusic() async {
    await _audioPlayer.pause();
  }

  void _changeSound(String soundKey) {
    setState(() {
      _selectedSound = soundKey;
    });
    Navigator.pop(context); // Đóng menu

    // Nếu đang chạy đồng hồ thì đổi nhạc luôn
    if (isRunning) {
      if (soundKey == 'none') {
        _pauseMusic();
      } else {
        _playMusic();
      }
    }
  }

  // Hàm thay đổi thời gian (Gọi khi chọn từ menu cài đặt)
  void _updateDuration(int minutes) {
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = selectedMinutes * 60;
      isRunning = false; // Dừng đồng hồ nếu đang chạy
    });
    _timer?.cancel();
    _pauseMusic();
    Navigator.pop(context); // Đóng menu chọn
  }

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      _pauseMusic();
    } else {
      _playMusic();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          _timer?.cancel();
          _pauseMusic();
          setState(() {
            isRunning = false;
          });
          _showCompletionDialog();
        }
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _pauseMusic();
    setState(() {
      remainingSeconds = selectedMinutes * 60;
      isRunning = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tuyệt vời! 🎉"),
        content:
            Text("Bạn đã hoàn thành phiên tập trung $selectedMinutes phút."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Text("Chọn âm thanh nền",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 20),

              // Các lựa chọn
              _buildSoundOption(
                  context, "Tắt âm thanh", Icons.volume_off_rounded, 'none'),
              _buildSoundOption(
                  context, "Tiếng mưa rơi", Icons.cloud_queue_rounded, 'rain'),
              _buildSoundOption(
                  context, "Lofi Chill", Icons.headphones_rounded, 'lofi'),
              _buildSoundOption(
                  context, "Chill Lofi", Icons.audiotrack_rounded, 'chill'),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundOption(
      BuildContext context, String title, IconData icon, String key) {
    final isSelected = _selectedSound == key;
    final theme = Theme.of(context);

    return ListTile(
      onTap: () => _changeSound(key),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : theme.scaffoldBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 2. Format chuỗi hiển thị đồng hồ: HH:MM:SS
  String get timerString {
    int hours = remainingSeconds ~/ 3600;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int seconds = remainingSeconds % 60;

    String hStr = hours.toString().padLeft(2, '0');
    String mStr = minutes.toString().padLeft(2, '0');
    String sStr = seconds.toString().padLeft(2, '0');

    // Nếu có giờ thì hiện 3 phần, không thì hiện MM:SS cho gọn (hoặc để luôn HH:MM:SS tùy ông)
    // Ở đây tôi để luôn HH:MM:SS nhìn cho pro
    return '$hStr:$mStr:$sStr';
  }

  // Helper: Chuyển số phút thành text đẹp (VD: 90 -> "1 giờ 30 phút")
  String _formatOnlyText(int totalMinutes) {
    if (totalMinutes < 60) return "$totalMinutes phút";
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    if (m == 0) return "$h giờ";
    return "$h giờ $m phút";
  }

  // Menu chọn thời gian (Bottom Sheet)
  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        // Danh sách các mốc thời gian gợi ý
        final List<int> options = [15, 25, 30, 45, 60, 90, 120, 180];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Chọn thời gian tập trung",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 20),

              // Lưới các nút chọn giờ
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((min) {
                  final isSelected = min == selectedMinutes;
                  return GestureDetector(
                    onTap: () => _updateDuration(min),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        _formatOnlyText(min),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tính phần trăm: (Thời gian hiện tại / Tổng thời gian đã chọn)
    final double percent = remainingSeconds / (selectedMinutes * 60);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Chế độ Tập trung",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isRunning ? "Hãy tập trung nào..." : "Sẵn sàng chưa?",
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            CircularPercentIndicator(
              radius: 130.0,
              lineWidth: 15.0,
              percent: percent > 1 ? 1 : percent, // Dùng biến percent động
              animation: true,
              animateFromLastPercent: true,
              center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerString,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                        letterSpacing: 2.0,
                      ),
                    ),
                    // Hiển thị thêm dòng nhỏ "25 phút" bên dưới để biết đang chọn mốc nào
                    if (!isRunning) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Chỉ rộng vừa đủ nội dung
                          children: [
                            Icon(
                              _selectedSound == 'rain'
                                  ? Icons.cloud_queue_rounded
                                  : (_selectedSound == 'lofi'
                                      ? Icons.headphones_rounded
                                      : Icons.volume_off_rounded),
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedSound == 'none'
                                  ? "Không có nhạc"
                                  : (_selectedSound == 'rain'
                                      ? "Tiếng mưa rơi"
                                      : "Lofi Chill"),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Mục tiêu: ${_formatOnlyText(selectedMinutes)}",
                        style: TextStyle(
                          fontSize: 11, // Chữ nhỏ hơn xíu cho phân cấp
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ]),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              progressColor: isRunning ? AppColors.primary : Colors.grey,
              widgetIndicator: isRunning
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút Reset
                CustomCircleButton(
                  icon: Icons.refresh_rounded,
                  onTap: resetTimer,
                ),

                const SizedBox(width: 20),

                CustomCircleButton(
                  // Nếu chưa chọn nhạc thì hiện icon tắt, chọn rồi thì hiện nốt nhạc
                  icon: _selectedSound == 'none'
                      ? Icons.music_off_rounded
                      : Icons.music_note_rounded,
                  // Nếu đang chọn nhạc thì đổi màu nút thành màu chính cho nổi bật
                  color: _selectedSound != 'none' ? AppColors.primary : null,
                  onTap: _showSoundPicker, // Gọi hàm hiện menu chọn nhạc
                ),

                const SizedBox(width: 20),

                // Nút Play/Pause
                GestureDetector(
                  onTap: toggleTimer,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(width: 30),

                // Nút Cài đặt - Đã gắn hàm _showTimePicker
                CustomCircleButton(
                  icon: Icons.settings_rounded,
                  onTap: _showTimePicker, // <--- GỌI HÀM NÀY
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
