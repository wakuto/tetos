OUTPUT_FORMAT("binary");

MEMORY {
    BOOT:ORIGIN=0x7C00,LENGTH=8k
    KERNEL:ORIGIN=0x101000,LENGTH=8k
}

SECTIONS {
    .text: {
        . = ALIGN(4);
        *(.text);

    }
}
