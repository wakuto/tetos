#define uint8 unsigned char
#define uint16 unsigned short
#define uint32 unsigned int
#define int8 char
#define int16 short
#define int32 int

//color 描画色 背景色(----IRGB):前景色(---TIRGB) T=透過, I=輝度
#define RED 0x04 | BRIGHTNESS
#define GREEN 0x02 | BRIGHTNESS
#define BLUE 0x01  | BRIGHTNESS
#define YELLOW (RED | GREEN)
#define PINK (RED | BLUE)
#define WHITE (YELLOW | BLUE)
#define BLACK 0x00
#define LIGHTBLUE (GREEN | BLUE)
#define DARK ~BTIGHTNESS &
#define BRIGHTNESS 0x08
#define TRANSPARENT 0x10
void draw_str(uint32 col, uint32 row, uint32 color, uint32 *p);

void draw_char(uint32 col, uint32 row, uint32 color, uint32 ch) {
    __asm__ (
        "mov col, %ecx \n\t"
        "mov row, %edx \n\t"
        "mov color, %ebx \n\t"
        "mov ch, %eax \n\t"
        "int $0x81 \n\t");
}

void draw_pixel(uint32 x, uint32 y, uint32 color) {
    // x : ecx
    // y : edx
    // color: ebx
    __asm__(
        "mov x, %ecx \n\t"
        "mov y, %edx \n\t"
        "mov color, %ebx \n\t"
        "int $0x82 \n\t");
}

void draw_block(uint32 x1, uint32 y1, uint32 x2, uint32 y2, uint32 color) {
    uint32 lx = (x1 < x2) ? x1 : x2;
    uint32 ly = (y1 > y2) ? y1 : y2;
    uint32 rx = (lx == x1) ? x2 : x1;
    uint32 ry = (ly == y1) ? y2 : y1;
    for(uint32 i = lx; i < rx; i++) {
        for(uint32 j = ly; j < ry; j++) {
            draw_pixel(i, j, color);
        }
    }
}
