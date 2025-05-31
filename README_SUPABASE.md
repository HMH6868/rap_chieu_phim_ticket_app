# Cài đặt Supabase cho ứng dụng HNP Cinema

## Giới thiệu
Tài liệu này hướng dẫn cách thiết lập Supabase để sử dụng cho chức năng đăng nhập, đăng ký và quản lý người dùng trong ứng dụng HNP Cinema.

## Bước 1: Tạo tài khoản Supabase

1. Truy cập [supabase.com](https://supabase.com) và đăng ký tài khoản
2. Sau khi đăng nhập, nhấn nút "New Project" để tạo dự án mới
3. Đặt tên cho dự án (ví dụ: "hnp-cinema")
4. Đặt mật khẩu cho database (hãy lưu lại an toàn)
5. Chọn region gần với người dùng của bạn
6. Nhấn "Create project" và đợi vài phút để dự án được tạo

## Bước 2: Lấy thông tin kết nối

1. Trong dashboard của dự án, chọn biểu tượng "cài đặt" (hình bánh răng) ở menu bên trái
2. Chọn "API" trong menu
3. Tại đây, bạn sẽ thấy:
   - URL: đây là địa chỉ Supabase của bạn
   - anon/public key: đây là khóa API công khai

## Bước 3: Cập nhật mã nguồn

Mở file `lib/utils/supabase_service.dart` và cập nhật phương thức `initialize()`:

```dart
static Future<void> initialize() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',  // Thay thế bằng URL từ bước 2
    anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Thay thế bằng anon key từ bước 2
  );
}
```

## Bước 4: Cấu hình Deep Linking

1. Đã thêm cấu hình deep linking vào AndroidManifest.xml với scheme là `hmh` và host là `vexemphim`.
2. Trong dashboard Supabase, chọn "Authentication" từ menu bên trái.
3. Chọn "URL Configuration".
4. Cấu hình các URL như sau:
   - Site URL: `https://YOUR_DOMAIN.com` (hoặc địa chỉ website chính thức của ứng dụng)
   - Redirect URLs: Thêm `hmh://vexemphim` vào danh sách
   
Điều này cho phép Supabase chuyển hướng người dùng trở lại ứng dụng khi họ nhấp vào liên kết xác minh email hoặc đặt lại mật khẩu.

## Bước 5: Bật tính năng xác thực email

1. Trong dashboard Supabase, chọn "Authentication" từ menu bên trái
2. Chọn "Providers" và đảm bảo "Email" đã được bật
3. (Tùy chọn) Cấu hình "Site URL" thành URL của ứng dụng của bạn

## Bước 6: Tùy chỉnh email templates (tùy chọn)

1. Trong phần Authentication, chọn "Email Templates"
2. Tại đây bạn có thể tùy chỉnh các mẫu email cho:
   - Xác minh email
   - Đặt lại mật khẩu
   - Mời người dùng
3. Trong mỗi mẫu, đảm bảo rằng các liên kết đang sử dụng `hmh://vexemphim` làm URL cơ sở cho nút hành động.

## Bước 7: Chạy ứng dụng

1. Chạy `flutter pub get` để cập nhật các dependencies
2. Chạy ứng dụng bằng `flutter run`

## Lưu ý quan trọng

- Trong môi trường production, hãy đảm bảo bạn đã cấu hình đúng Site URL và Redirect URLs trong Supabase Authentication Settings
- Đối với ứng dụng di động, cần đảm bảo Deep Links được cấu hình đúng để xử lý các liên kết xác minh email và đặt lại mật khẩu
- Nếu bạn muốn lưu trữ thêm thông tin người dùng (như tên, hình ảnh, v.v.), hãy tạo bảng `profiles` trong Supabase và liên kết với auth.users qua trường user_id

## Xử lý sự cố

1. **Không thể đăng nhập hoặc đăng ký**:
   - Kiểm tra URL và API key đã đúng chưa
   - Đảm bảo Email auth provider đã được bật trong Supabase

2. **Không nhận được email xác minh**:
   - Kiểm tra thư mục spam
   - Kiểm tra cấu hình email trong Supabase

3. **Không thể đặt lại mật khẩu**:
   - Đảm bảo đã cấu hình đúng Site URL và Redirect URLs 
   - Kiểm tra scheme và host trong AndroidManifest.xml có khớp với cấu hình trong Supabase không 