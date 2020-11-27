; C言語と同等の関数呼び出し
%macro cdecl 1-*.nolist ; 可変引数, リスト出力の抑止

    %rep %0 - 1         ; 引数の数-1回
        push %{-1:-1}   ; 一番最後の引数
        %rotate -1      ; 一番最後の引数を先頭に移動
    %endrep
    %rotate -1      ; 回転をもとに戻す

    call %1         ; 第１引数を呼び出し

    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)  ; cpuのbyte数(bit数/8) * 引数の数-1
    %endif
%endmacro

struc drive
    .no resw 1      ; ドライブ番号
    .cyln resw 1    ; シリンダ
    .head resw 1    ; ヘッド
    .sect resw 1    ; セクタ
endstruc

%macro set_vect 1-*
        push eax
        push edi

        mov edi, VECT_BASE + (%1 * 8)   ; ベクタアドレス
        mov eax, %2

    %if 3 == %0
        mov [edi + 4], %3               ; フラグ
    %endif

        mov [edi + 0], ax       ; 例外アドレス[15: 0]
        shr eax, 16
        mov [edi + 6], ax       ; 例外アドレス[31:16]

        pop edi
        pop eax
%endmacro

%macro outp 2
    mov al, %2
    out %1, al
%endmacro

%define RING_ITEM_SIZE (1 << 4)
%define RING_INDEX_MASK (RING_ITEM_SIZE - 1)

struc ring_buff
    .rp resd 1                  ; RP:書き込み位置
    .wp resd 1                  ; WP:読み込み位置
    .item resb RING_ITEM_SIZE   ; バッファ
endstruc

%macro set_desc 2-*
        push eax
        push edi

        mov edi, %1     ; ディスクリプタアドレス
        mov eax, %2     ; ベースアドレス

    %if 3 == %0
        mov [edi + 0], %3   ; リミット
    %endif

        mov [edi + 2], ax   ; ベース([15: 0])
        shr eax, 16
        mov [edi + 4], al   ; ベース([23:16])
        mov [edi + 7], ah   ; ベース([31:24])

        pop edi
        pop eax
%endmacro

%macro set_gate 2-*
    push eax
    push edi

    mov edi, %1         ; ディスクリプタアドレス
    mov eax, %2         ; ベースアドレス

    mov [edi + 0], ax   ; ベース([15: 0])
    shr eax, 16
    mov [edi + 6], ax   ; ベース([31:16])

    pop edi
    pop eax
%endmacro

struc rose
    .x0         resd 1      ; 左上座標
    .y0         resd 1      ; 
    .x1         resd 1      ; 右下座標
    .y1         resd 1      ;

    .n          resd 1      ; 変数n
    .d          resd 1      ; 変数d

    ;描画色
    .color_x    resd 1      ; x軸
    .color_y    resd 1      ; y軸
    .color_z    resd 1      ; 枠
    .color_s    resd 1      ; 文字
    .color_f    resd 1      ; グラフ描画
    .color_b    resd 1      ; グラフ消去

    .title      resb 16     ; タイトル
endstruc
