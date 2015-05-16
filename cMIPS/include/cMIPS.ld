SECTIONS
{
       . = 0x00000000; /* x_INST_BASE_ADDR */
       .text : { *(.text .text.*) }
       . = 0x00040000; /* x_DATA_BASE_ADDR */
       .data    : { *(.data .data.*) }
       .rodata  : { *(.rodata .rodata.*) }
       .rodata1 : { *(.rodata1) }
       .data1   : { *(.data1) }
       .sdata   : { *(.sdata .sdata.*) }
       .lit8    : { *(.lit8) }
       .lit4    : { *(.lit4) }
       .sbss    : { *(.sbss .sbss.*) *(.scommon .scommon.*) }
       .bss     : { *(.bss .bss.*) *(COMMON) }
}

