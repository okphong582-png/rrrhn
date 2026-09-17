# Cập nhật ESP từ ofs.txt

15 giá trị liên quan đến ESP đã được chép đúng từ `ofs.txt` vào
`esp/Core/GameOffsets.h`. Người cung cấp xác nhận bộ offset dành cho iOS ARM64;
chưa có số phiên bản game hoặc kết quả kiểm tra trên thiết bị.

Các điểm đọc đã được nối lại: GameFacade, static fields, trận đấu, local player,
danh sách người chơi, trạng thái chết, PlayerID, camera transform, đầu và bàn
chân phải. Hàm đọc tên và trường Player_Data cũng dùng giá trị mới. Những offset
vũ khí/kỹ năng không được thêm vì ESP hiện tại không sử dụng chúng.

Camera sử dụng chuỗi suy ra từ tên trường trong file:
`localPlayer + FollowCamera -> Camera -> native camera + ViewMatrix`.
Điểm dưới của khung sử dụng `RightFoot`, không còn hàm mang tên `RightToeNode`.
Khung không còn phụ thuộc vào đọc tên hoặc HP vì giao diện hiện tại chỉ vẽ box.

Các cấu trúc chưa được file mới mô tả vẫn dùng bố cục ARM64 cũ: current-game
instance tại static fields + 0, native camera + 0x10, cấu trúc dictionary/array,
wrapper và dữ liệu transform, PlayerID, chuỗi UTF-16 và cấu trúc bên trong
Player_Data. Đặc biệt, việc Player_Data vẫn là pool HP cũ chưa được xác minh;
các hàm HP không được gọi trong đường vẽ box.

Vẫn cần xác minh bố cục bộ nhớ: các trường Head = 0x49C, Hip = 0x4A0 và
Neck = 0x4A4 trong file chỉ cách nhau 4 byte, trong khi bộ đọc dùng con trỏ
8 byte. Không thể kết luận bộ offset tương thích ARM64 chỉ từ tên trường hoặc
việc các giá trị đã được chép đúng.

Đã bổ sung xử lý đọc thất bại, tự tìm lại game khi chưa mở hoặc tiến trình đã
thoát, xóa box cũ khi không còn dữ liệu, giới hạn duyệt transform, và bỏ các
điểm chiếu phía sau camera hoặc không hữu hạn. Màu nền app đã chuyển sang đỏ
ở cả chế độ sáng và tối.

Môi trường Windows hiện không có Theos/iOS SDK nên chưa tạo bản `.tipa` hay
chạy trên iPhone. Đã đối chiếu 15/15 hằng offset với file đầu vào và chạy đạt
24/24 ca kiểm tra C++ bằng MSVC với bộ nhớ mô phỏng, gồm lỗi đọc, dữ liệu một
phần, chỉ số xương sai, vòng lặp cha, biến đổi tọa độ và phép chiếu màn hình.
Các kiểm tra này không thay thế việc build iOS và kiểm tra trong game. Trên môi trường
Theos đã cấu hình theo README, dùng `make clean package`, sau đó kiểm tra mở
HUD trước/sau game, vào/ra trận và mở lại game để xác nhận kết nối và box.
