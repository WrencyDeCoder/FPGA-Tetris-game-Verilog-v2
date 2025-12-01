# from PIL import Image

# # --- Cấu hình kích thước khung hình VGA ---
# WIDTH = 640
# HEIGHT = 480

# # --- Đọc dữ liệu từ file frame.hex ---
# pixels = []
# with open("C:/altera/13.0sp1/frame.hex", "r") as f:
#     for line in f:
#         hex_value = line.strip()
#         if len(hex_value) == 6:
#             # Tách các kênh màu
#             R = int(hex_value[0:2], 16)
#             G = int(hex_value[2:4], 16)
#             B = int(hex_value[4:6], 16)
#             pixels.append((R, G, B))

# # --- Kiểm tra số pixel ---
# expected_pixels = WIDTH * HEIGHT
# if len(pixels) != expected_pixels:
#     print(f"Cảnh báo: có {len(pixels)} pixel, dự kiến {expected_pixels}")

# # --- Tạo ảnh BMP ---
# img = Image.new("RGB", (WIDTH, HEIGHT))
# img.putdata(pixels[:expected_pixels])
# img.save("frame.bmp")

# print("✅ Đã tạo file frame.bmp thành công!")


from PIL import Image
import os

WIDTH, HEIGHT = 640, 480

for i in range(27):
    hex_file = f"D:/HK5/testbench/frame_{i}.hex"
    bmp_file = f"tb_img/frame_{i}.bmp"

    if not os.path.exists(hex_file):
        print(f"File {hex_file} not found, skipping.")
        continue

    print(f"Converting {hex_file} → {bmp_file}...")

    with open(hex_file, "r") as f:
        lines = [line.strip() for line in f if line.strip()]

    pixels = []
    for hex_color in lines:
        if len(hex_color) >= 6:
            r = int(hex_color[0:2], 16)
            g = int(hex_color[2:4], 16)
            b = int(hex_color[4:6], 16)
            pixels.append((r, g, b))
        else:
            pixels.append((0, 0, 0))

    # Bảo đảm đủ pixel
    while len(pixels) < WIDTH * HEIGHT:
        pixels.append((0, 0, 0))

    img = Image.new("RGB", (WIDTH, HEIGHT))
    img.putdata(pixels[:WIDTH * HEIGHT])
    img.save(bmp_file)

print("Done!")
