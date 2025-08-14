//private file
//+build linux
#+build !windows
package main

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:path/filepath"
import os "core:os/os2"

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

//Path_Separator :: os.Path_Separator
Path_Separator_String :: os.Path_Separator_String
//Path_List_Separator :: os.Path_List_Separator
Path_List_Separator_String :: ":"

@(private = "package")
setup_linux :: proc() -> int {
	//dump_icon()
	return 0
}
