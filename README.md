"# FPGA-Tetris-game-Verilog-v2" 
# FPGA-Tetris-game-Verilog-v2 🎮

Một triển khai hoàn chỉnh của trò chơi **Tetris** trên FPGA (kit Altera DE2 + tín hiệu VGA), viết bằng Verilog.  
Mục tiêu của project là xây dựng một game Tetris hoạt động trên phần cứng, với full logic: sinh khối, di chuyển, xoay, va chạm, xóa hàng, tính điểm, game over, và hiển thị lên màn hình ngoài qua cổng VGA.

---

## 📂 Nội dung repo

| File / Module | Chức năng |
|---------------|-----------|
| `topDE2.v` | Module top — kết nối toàn bộ khối con, ánh xạ chân FPGA, phát lock-up file cấu hình |
| `vga_controller.v` | Bộ điều khiển VGA: sinh hsync/vsync, blanking, tính tọa độ pixel (x, y), phân biệt vùng hiển thị (active area) theo chuẩn VGA 640×480 @ 60 Hz |
| `game_logic_controller.v` | Logic chính của trò chơi: quản lý lưới, khối hiện tại, khối kế tiếp, xử lý input, kiểm tra va chạm, xóa hàng, tính điểm, game over, FSM game |
| `collision.v` | Module kiểm tra va chạm khối — đảm bảo khối không vượt biên, không chồng lên khối đã cố định |
| `input_handler.v` | Xử lý tín hiệu từ nút bấm/switch (KEY, SW) trên DE2, có xử lý debounce / lọc tín hiệu nếu cần |
| `randomizer.v` | Sinh ngẫu nhiên khối mới (tetromino) — giả lập chức năng random block (tetromino generator) |
| `score_digit_rom.v`, `game_over_text_rom.v` | ROM mã hoá font chữ / số: dùng để hiển thị điểm, text “GAME OVER” trên VGA |
| `definitions.vh` | File chứa các tham số chung: chiều rộng/ cao màn hình, timing VGA (H_VISIBLE, H_SYNC, porch, total, v.v.), các hằng số game (chiều rộng board, cao, v.v.) |

---

## ✅ Tính năng chính

- Game Tetris hoạt động hoàn toàn trên FPGA, không cần soft-core processor.  
- Hiển thị lên màn hình ngoài thông qua VGA 640×480 @ 60 Hz.  
- Di chuyển khối trái – phải, xoay, rơi nhanh.  
- Sinh khối ngẫu nhiên, duy trì logic xóa hàng, nén lưới, cập nhật điểm.  
- Có xử lý va chạm, kiểm tra biên, đảm bảo khối không chồng/lấn/ra khỏi lưới.  
- Xử lý input từ phím bấm/switch của DE2.  
- Hiển thị điểm số và trạng thái “Game Over”.  

---

## 🧰 Yêu cầu & Cách chạy

### Phần cứng

- Board **Altera DE2** (FPGA Cyclone II) hoặc board tương thích.  
- Màn hình ngoài hỗ trợ VGA, cáp VGA.  

### Phần mềm

- Quartus II (phiên bản tương thích với Cyclone II).  
- Phần mềm nạp cấu hình FPGA (qua JTAG / USB-Blaster).  

### Hướng dẫn sử dụng

1. Clone repo:  
   ```bash
   git clone https://github.com/WrencyDeCoder/FPGA-Tetris-game-Verilog-v2.git
Mở Quartus II, tạo project mới hoặc dùng file project có sẵn.

Thêm toàn bộ file Verilog / definitions / constraints pin-assignment tương ứng với kit DE2.

Gán chân (Pin Assignment): CLOCK_50, KEY[3:0], SW[9:0], VGA_R/G/B, VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK,... phù hợp với sơ đồ pinout của DE2.

Biên dịch (Analysis & Synthesis → Fitter). Nếu không có lỗi, tiến hành generate file configuration (.sof).

Nạp file .sof vào FPGA Cyclone II (qua JTAG / USB-Blaster).

Kết nối VGA → màn hình, bật nguồn. Giao diện ban đầu của game Tetris sẽ hiện lên. Bạn có thể dùng phím/switch để chơi.

🎥 Demo & Video thử nghiệm

Bạn có thể xem video demo quá trình chơi thử nghiệm trên kit DE2 + màn hình ngoài tại:
[YouTube link của bạn] (thêm link ở đây)

🧑‍💻 Cấu trúc & Kiến trúc thiết kế

Thiết kế tuân theo mô hình phân tách display logic (VGA) — game logic. Cụ thể:

vga_controller.v chỉ đảm nhận phần timing VGA, sinh xung HSync/VSync/blank, sinh tọa độ pixel, xác định vùng hiển thị (active_area).

game_logic_controller.v + các module phụ chịu trách nhiệm logic trò chơi: quản lý lưới, khối, điểm số, input, collision, v.v.

Hai phần được kết nối thông qua bus đơn giản: tại mỗi pixel (x, y), nếu active_area = 1 thì game logic quyết định màu RGB sẽ xuất ra; còn nếu active_area = 0 → xuất màu nền / blanking.

Cách phân tách này giúp:

Logic hiển thị & timing VGA đồng bộ, ổn định, không phụ thuộc vào tốc độ game.

Logic game chạy độc lập theo “frame logic” (tốc độ chậm hơn), dễ điều chỉnh tốc độ rơi, phản hồi input, v.v.

Dễ bảo trì, mở rộng — ví dụ thêm tính năng mới mà không ảnh hưởng VGA timing.

📁 Cấu trúc thư mục (gốc repo)
/                  # root  
  ├─ topDE2.v  
  ├─ vga_controller.v  
  ├─ game_logic_controller.v  
  ├─ collision.v  
  ├─ input_handler.v  
  ├─ randomizer.v  
  ├─ score_digit_rom.v  
  ├─ game_over_text_rom.v  
  ├─ definitions.vh  
  └─ (nếu có) file constraints / pin assignment  

📝 Ghi chú / Hạn chế & Hướng phát triển

Hiện tại chỉ hỗ trợ độ phân giải 640×480. Nếu muốn nâng độ phân giải hoặc chuyển sang màu sâu hơn, cần điều chỉnh vga_controller.v và các tham số timing.

Randomizer đơn giản — không hỗ trợ “bag random” hoặc hệ thống random phức tạp như các bản Tetris hiện đại.

Giao diện đồ họa cơ bản — không có âm thanh, không có hiệu ứng đồ họa tinh vi.

Có thể mở rộng: thêm menu, lưu cao điểm, nhiều level, tăng tốc độ theo thời gian, hỗ trợ joystick/Gamepad, v.v.

👥 Tác giả & Liên hệ

Kinn (Khoi) — học viên ngành Kỹ thuật Máy tính, ĐH CNTT.

Nếu có vấn đề, lỗi, hoặc góp ý — bạn có thể mở issue trên GitHub hoặc liên hệ qua email / nền tảng bạn thích.

📜 License

Bạn có thể thêm license nếu muốn — ví dụ MIT, BSD hoặc license phù hợp. Nếu chưa chọn, mặc định là All rights reserved.


---

### ✨ Vì sao README như thế này là hợp lý?

- README giúp người xem hiểu nhanh **mục tiêu**, **tính năng**, **cách chạy** và **cấu trúc** của project — đúng như các khuyến nghị phổ biến về README “tốt” trên GitHub: dễ hiểu, rõ ràng, đầy đủ thông tin hướng dẫn. :contentReference[oaicite:3]{index=3}  
- Việc chia rõ các phần: “Giới thiệu”, “Cách chạy”, “Cấu trúc/Kiến trúc”, “Tác giả”, “License” giúp người mới vào repo dễ nắm thông tin và có thể chạy / tái sử dụng code mà không phải mò mẫm.

---

Nếu muốn — mình có thể **viết luôn README tiếng Việt + tiếng Anh song song** cho repo này (bilingual), để phù hợp với cả giảng viên & cộng đồng quốc tế — bạn muốn mình làm luôn?
::contentReference[oaicite:4]{index=4}
