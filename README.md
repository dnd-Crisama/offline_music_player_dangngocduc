# Offline Music Player

Ứng dụng nghe nhạc Flutter được thiết kế để phát các file audio cục bộ và file mẫu, quản lý playlist, tìm kiếm bài hát, và hiển thị mini player gọn nhẹ.

## Mô tả dự án và tính năng

Offline Music Player được xây dựng cho phát nhạc cục bộ với giao diện Material sạch và trực quan. Ứng dụng hỗ trợ:

- Màn hình chính với danh sách bài hát
- Màn hình Now Playing với điều khiển phát đầy đủ
- Mini player hiển thị khi điều hướng qua các màn hình khác
- Tạo playlist và duyệt các playlist
- Tìm kiếm bài hát theo tên, nghệ sĩ và album
- Màn hình cài đặt cho tùy chọn ứng dụng và quyền truy cập
- Hộp thoại yêu cầu quyền truy cập âm thanh trên Android
- Tự động sử dụng file âm thanh mẫu khi không tìm thấy bài hát 

## Hướng dẫn cài đặt

1. Cài đặt Flutter SDK và thiết lập môi trường phát triển:
   - Flutter tương thích với Dart SDK `^3.11.4`
   - Android SDK có sẵn trình giả lập hoặc thiết bị Android thật
2. Sao chép kho lưu trữ:
   ```bash
   git clone <repository-url>
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

Thêm ảnh chụp màn hình vào thư mục `screenshots/` và cập nhật đường dẫn hình ảnh bên dưới nếu cần.

- Màn hình chính với danh sách bài hát
<img width="490" height="900" alt="image" src="https://github.com/user-attachments/assets/03585669-68fe-4661-bd80-6619f340c8a8" />
<br>
- Màn hình Now Playing
<img width="487" height="900" alt="image" src="https://github.com/user-attachments/assets/b85dea99-1166-4800-87b5-7718628b9681" />
<br>
- Mini player
<img width="386" height="268" alt="image" src="https://github.com/user-attachments/assets/251b37c3-999c-4215-b22b-8701fa78d035" />
- Màn hình Playlist
<img width="459" height="898" alt="image" src="https://github.com/user-attachments/assets/fc30ee26-0808-49bb-99b2-f919bb0ad279" />
<br>
<img width="466" height="889" alt="image" src="https://github.com/user-attachments/assets/0d9485f9-2bb1-4035-9ccd-0152dcfc10d1" />
<br>
<img width="498" height="892" alt="image" src="https://github.com/user-attachments/assets/a042a243-d6e7-43cc-af83-82c8f5ba2c17" />
<br>
- Màn hình Tìm kiếm
<img width="462" height="892" alt="image" src="https://github.com/user-attachments/assets/7605a0b1-2266-4547-8bbe-f0ba443df991" />
<br>
- Màn hình Cài đặt
<img width="454" height="890" alt="image" src="https://github.com/user-attachments/assets/29b16f67-6cf9-44ad-a66f-1fb3a8e7c8f4" />
<br>
- Hộp thoại yêu cầu quyền
<img width="413" height="862" alt="image" src="https://github.com/user-attachments/assets/8189c767-4bd1-4394-9fcf-8baa0c3afd08" />

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
- Thêm cải tiến dành cho iOS và hoàn thiện đa nền tảng.

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
