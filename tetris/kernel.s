%define USE_SYSTEM_CALL
%define USE_TEST_AND_SET

%include "../include/define.s"
%include "../include/macro.s"

    ORG KERNEL_LOAD

[BITS 32]   ; 32bitコードを生成

; エントリポイント
kernel:
    ; フォントアドレスを取得
    mov esi, BOOT_LOAD + SECT_SIZE  ; 0x7C00 + 512  フォントアドレス
    movzx eax, word [esi + 0]       ; FONT.seg  セグメント
    movzx ebx, word [esi + 2]       ; FONT.off  オフセット
    shl eax, 4
    add eax, ebx
    mov [FONT_ADR], eax

    ; TSSディスクリプタの設定
    set_desc GDT.tss_0, TSS_0       ; タスク0用TSSの設定
    set_desc GDT.tss_1, TSS_1       ; タスク1用TSSの設定
    set_desc GDT.tss_2, TSS_2       ; タスク2用TSSの設定
    set_desc GDT.tss_3, TSS_3       ; タスク3用TSSの設定
    set_desc GDT.tss_4, TSS_4       ; タスク4用TSSの設定
    set_desc GDT.tss_5, TSS_5       ; タスク5用TSSの設定
    set_desc GDT.tss_6, TSS_6       ; タスク6用TSSの設定

    ; コールゲートの設定
    set_gate GDT.call_gate, call_gate   ; コールゲートの設定

    ; LDTの設定
    set_desc GDT.ldt, LDT, word LDT_LIMIT

    ; GDTをロード(再設定)
    lgdt [GDTR]         ; グローバルディスクリプタテーブルをロード

    ; スタックの設定
    mov esp, SP_TASK_0  ; タスク0用のスタックを設定

    ; タスクレジスタの初期化
    mov ax, SS_TASK_0   ; これからタスク0として動作する
    ltr ax              ; タスクレジスタの設定

    ; 初期化
    cdecl init_int                  ; 割り込みベクタの初期化
    cdecl init_pic                  ; 割り込みコントローラの初期化
    cdecl init_page                 ; ページングの初期化

    set_vect 0x00, int_zero_div     ; 割り込み処理の登録：0除算
    set_vect 0x07, int_nm           ; 割り込み処理の登録：デバイス使用不可例外
    set_vect 0x0E, int_pf           ; 割り込み処理の登録：ページフォルト
    set_vect 0x20, int_timer        ; 割り込み処理の登録：タイマー
    set_vect 0x21, int_keyboard     ; 割り込み処理の登録：KBC
    set_vect 0x28, int_rtc          ; 割り込み処理の登録：RTC
    set_vect 0x81, trap_gate_81, word 0xEF00    ; トラップゲートの登録:1文字出力
    set_vect 0x82, trap_gate_82, word 0xEF00    ; トラップゲートの登録:点の描画

    ; デバイスの割り込み許可
    cdecl rtc_int_en, 0x10          ; rtc_int_en(UIE) 更新サイクル終了前割り込み許可
    cdecl int_en_timer0             ; タイマー割り込み許可

    ; IMR（割り込みマスクレジスタ）の設定
    outp 0x21, 0b1111_1000          ; 割り込み有効：スレーブPIC/KBC/タイマー
    outp 0xA1, 0b1111_1110          ; 割り込み有効：RTC

    ; ページングの有効化
    mov eax, CR3_BASE
    mov cr3, eax                    ; ページテーブルの登録

    mov eax, cr0
    or eax, (1 << 31)               ; CR0 | PG      ページングを有効化
    mov cr0, eax
    jmp $ + 2                       ; パイプラインのクリア

    sti                             ; 割り込み許可

    cdecl draw_font, 63, 13         ; フォント一覧表示
    cdecl draw_color_bar, 63, 4     ; カラーバーを表示
    cdecl draw_str, 25, 14, 0x010F, .s0 ; 文字の表示



.10L:
    ; 回転する棒の表示
    cdecl draw_rotation_bar

    ; キーコードの取得
    cdecl ring_rd, _KEY_BUFF, .int_key
    cmp eax, 0
    je .10E

    ; キーコードの表示
    cdecl draw_key, 2, 29, _KEY_BUFF

    ; キー押下時の処理
    mov al, [.int_key]
    cmp al, 0x02
    jne .12E
    ; ファイル読み込み
    call [BOOT_LOAD + BOOT_SIZE - 16]   ; ファイル読み込み

    ; ファイルの内容を表示
    mov esi, 0x7800
    mov [esi + 32], byte 0
    cdecl draw_str, 0, 0, 0x0F04, esi
.12E:

    ; CTRL+ALT+ENDキー
    mov al, [.int_key]
    cdecl ctrl_alt_end, eax
    cmp eax, 0
    je .14E

    mov eax, 0
    bts [.once], eax
    jc .14E
    cdecl power_off     ; 1度だけ呼び出す
.14E:

.10E:
    jmp .10L

.s0 db " Hello, kernel! ", 0

ALIGN 4,    db 0
.int_key:   dd 0
.once:      dd 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

; タスク
%include "descriptor.s"
%include "modules/int_timer.s"
%include "modules/paging.s"
%include "modules/int_pf.s"
%include "tasks/task_1.s"
%include "tasks/task_2.s"
%include "tasks/task_3.s"

; モジュール
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"
%include "../modules/protect/draw_rect.s"
%include "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"
%include "../modules/protect/interrupt.s"
%include "../modules/protect/pic.s"
%include "../modules/protect/int_rtc.s"
%include "../modules/protect/int_keyboard.s"
%include "../modules/protect/ring_buff.s"
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"
%include "../modules/protect/call_gate.s"
%include "../modules/protect/trap_gate.s"
%include "../modules/protect/test_and_set.s"
%include "../modules/protect/int_nm.s"
%include "../modules/protect/wait_tick.s"
%include "../modules/protect/memcpy.s"
%include "../modules/protect/acpi_find.s"
%include "../modules/protect/acpi_package_value.s"
%include "../modules/protect/find_rsdt_entry.s"
%include "../modules/protect/power_off.s"
%include "../modules/protect/ctrl_alt_end.s"

;パディング
    times KERNEL_SIZE - ($ - $$) db 0

; FAT
%include "fat.s"
