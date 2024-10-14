//private file
//+build linux
package main

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:path/filepath"

BYTE :: u8
WORD :: u16
DWORD :: u32
LONG :: i32

RGBQUAD :: struct {
	rgbBlue: BYTE,
	rgbGreen: BYTE,
	rgbRed: BYTE,
	rgbReserved: BYTE,
}

BITMAPINFOHEADER :: struct {
	biSize:          DWORD,
	biWidth:         LONG,
	biHeight:        LONG,
	biPlanes:        WORD,
	biBitCount:      WORD,
	biCompression:   DWORD,
	biSizeImage:     DWORD,
	biXPelsPerMeter: LONG,
	biYPelsPerMeter: LONG,
	biClrUsed:       DWORD,
	biClrImportant:  DWORD,
}

_Path_Separator :: '/'
_Path_Separator_Str :: "/"
_Path_List_Separator :: ':'
_Path_List_Separator_Str :: ":"

@(private = "package")
setup_linux :: proc() -> int {
	//dump_icon()
	return 0
}
