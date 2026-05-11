# Offline Music Player

Ứng dụng nghe nhạc Flutter được thiết kế để phát các file audio cục bộ và file mẫu, quản lý playlist, tìm kiếm bài hát, và hiển thị mini player gọn nhẹ.

## Mô tả dự án và tính năng

Offline Music Player được xây dựng cho phát nhạc cục bộ với giao diện Material sạch và trực quan. Ứng dụng hỗ trợ:

- Màn hình chính với danh sách bài hát
- Màn hình Now Playing với điều khiển phát đầy đủ
- Mini player hiển thị khi điều hướng qua các màn hình khác
- Tạo playlist và duyệt các playlist
- Tìm kiếm bài hát theo tên, nghệ sĩ và album
- Màn hình cài đặt cho tùy chọn ứng dụng
- Playyback có sleeptimer và playback speed
- Nhạc chạy dưới nền
- Thêm bài hát yêu thích
- Shuffle bài hát và Loop
- Tinh chỉnh âm lượng
- Tự động sử dụng file âm thanh mẫu khi không tìm thấy bài hát
- Light mode - Dark mode

## Video demo
https://github.com/user-attachments/assets/7e0b2254-db77-464f-8ab2-436c9e684c12

## Hướng dẫn cài đặt

1. Cài đặt Flutter SDK và thiết lập môi trường phát triển:
   - Flutter tương thích với Dart SDK `^3.11.4`
   - Android SDK có sẵn trình giả lập hoặc thiết bị Android thật
2. Sao chép kho lưu trữ:
   ```bash
   git clone https://github.com/dnd-Crisama/offline_music_player_dangngocduc.git
   cd offline_music_player
   ```
3. Cài đặt phụ thuộc:
   ```bash
   flutter pub get
   ```
4. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Ảnh chụp màn hình của các giao diện

- Màn hình chính với danh sách bài hát
<img width="471" height="883" alt="image" src="https://github.com/user-attachments/assets/edd21215-dd80-4b22-85f7-4036fa03fe9d" />
<br>
<img width="456" height="861" alt="image" src="https://github.com/user-attachments/assets/eceff057-408c-4390-a099-52a6722d095e" />
<br>
- Màn hình Now Playing
<img width="440" height="866" alt="image" src="https://github.com/user-attachments/assets/c3972ed6-2553-4c87-8e8d-9b04ab6ee074" />
<br>
- Sleep timer
<img width="442" height="871" alt="image" src="https://github.com/user-attachments/assets/11d80e4b-bba0-4bf3-a88c-ec261b7c44b2" />
<br>
- Playback speed
<img width="447" height="866" alt="image" src="https://github.com/user-attachments/assets/af97e9d0-690e-4be5-8f57-177f9a8e8aaa" />
<br>
<img width="440" height="863" alt="image" src="https://github.com/user-attachments/assets/cf51b5fe-7b27-4fe4-9ebb-22e584a1d035" />
<br>
- Mini player
<img width="378" height="120" alt="image" src="https://github.com/user-attachments/assets/50494a39-9a67-45d0-a753-aee38d852d31" />

- Màn hình Playlist
<img width="437" height="876" alt="image" src="https://github.com/user-attachments/assets/31e908c9-321d-4fdd-9dbf-640b9fac0d42" />
<br>
<img width="440" height="882" alt="image" src="https://github.com/user-attachments/assets/3cd7c9ec-daf8-4d36-b27c-2cdfe168ba3c" />
<br>
<img width="460" height="869" alt="image" src="https://github.com/user-attachments/assets/d9acd73a-67b4-430f-b167-8831bf02eda9" />
<br>
- Màn hình Tìm kiếm
<img width="446" height="867" alt="image" src="https://github.com/user-attachments/assets/d533e85c-cf09-44ae-89cf-23c859001161" />
<br>
<img width="425" height="862" alt="image" src="https://github.com/user-attachments/assets/b1bbb4eb-b725-4bc6-b7b5-74c0d4bfab95" />
<br>
- Màn hình Cài đặt
<img width="435" height="876" alt="image" src="https://github.com/user-attachments/assets/d4f5a946-b56e-44c3-84e8-cfba8b2c5a40" />
<br>
- Hộp thoại yêu cầu quyền
<img width="413" height="862" alt="image" src="https://github.com/user-attachments/assets/8189c767-4bd1-4394-9fcf-8baa0c3afd08" />
<br>
- Light mode
<img width="447" height="877" alt="image" src="https://github.com/user-attachments/assets/36e970a6-bb1a-4aae-a586-e64dea8447ab" />
<br>
<img width="442" height="869" alt="image" src="https://github.com/user-attachments/assets/0b851179-2185-4bee-b01c-75c1c51f0551" />
<br>
<img width="442" height="880" alt="image" src="https://github.com/user-attachments/assets/28463879-47cf-4f59-9c15-c0fbc39361a7" />
<br>
## Cách thêm file nhạc để thử nghiệm

1. Đặt file MP3 vào thư mục `assets/audio/sample_songs/`.
2. Ứng dụng đã bao gồm ba file âm thanh mẫu mặc định:
   - `assets/audio/sample_songs/song1.mp3`
   - `assets/audio/sample_songs/song2.mp3`
   - `assets/audio/sample_songs/song3.mp3`
3. `pubspec.yaml` đã khai báo thư mục `assets/audio/sample_songs/` làm tài sản ứng dụng.
4. Khởi động lại ứng dụng sau khi thêm hoặc thay đổi file.

> Lưu ý: Ứng dụng sẽ cố gắng truy vấn audio ngoài trên Android. Nếu không tìm thấy bài hát ngoài hoặc quyền bị từ chối, ứng dụng sẽ tự động sử dụng các bài hát mẫu đi kèm.

## Công nghệ sử dụng

- Flutter
- Dart
- just_audio
- audio_service
- provider
- shared_preferences
- path_provider
- permission_handler
- on_audio_query
- audio_session
- rxdart
- palette_generator

## Ghi nhận âm nhạc

Các file âm thanh mẫu được lưu trong `assets/audio/sample_songs/`. Chúng được cung cấp làm nội dung thử nghiệm để phát triển và demo.

Xem `MUSIC_CREDITS.md` để biết chi tiết nguồn và hướng dẫn ghi nhận.

## Hạn chế đã biết

- Việc lưu playlist có thể bị hạn chế và không đảm bảo tồn tại sau mỗi lần khởi động lại.
- Tìm kiếm chỉ là so khớp văn bản đơn giản, chưa hỗ trợ lọc nâng cao.
- Ứng dụng phụ thuộc vào quyền truy cập audio ngoài trên Android; một số thiết bị có thể yêu cầu cấp quyền rõ ràng.
- Metadata của file âm thanh mẫu được mã hóa cứng cho các tài sản đã đóng gói.
- Chưa có tính năng tải ảnh bìa album tự động hoặc hỗ trợ thư viện nhạc trực tuyến.

## Cải tiến trong tương lai

- Thêm điều khiển phát trên màn hình khóa và thông báo.
- Cải thiện bộ lọc tìm kiếm và khám phá nghệ sĩ/album.
- Hỗ trợ ảnh bìa album tốt hơn và bộ nhớ đệm.

## Cấu trúc kho lưu trữ

```
offline_music_player/
├── README.md
├── MUSIC_CREDITS.md
├── screenshots/
├── lib/
├── test/
├── assets/
│   ├── audio/
│   │   └── sample_songs/
│   └── images/
└── pubspec.yaml
```
