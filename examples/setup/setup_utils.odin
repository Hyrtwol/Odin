#+private file
package main

import "base:intrinsics"
import "core:fmt"
import os "core:os/os2"
import "core:path/filepath"

/*
typedef struct ICONDIR {
    WORD          idReserved;
    WORD          idType;
    WORD          idCount;
    ICONDIRENTRY  idEntries[];
} ICONHEADER;

struct IconDirectoryEntry {
    BYTE  bWidth;
    BYTE  bHeight;
    BYTE  bColorCount;
    BYTE  bReserved;
    WORD  wPlanes;
    WORD  wBitCount;
    DWORD dwBytesInRes;
    DWORD dwImageOffset;
};
*/
Icon_File_Header :: struct #packed {
	Reserved:  WORD, // Reserved (2 bytes), always 0
	IconType:  WORD, // IconType (2 bytes), if the image is an icon it's 1, for cursors the value is 2.
	IconCount: WORD, // IconCount (2 bytes), number of icons in this file.
}
#assert(size_of(Icon_File_Header) == 6)

Icon_Directory_Entry :: struct #packed {
	Width:       BYTE, // (1 byte), Width of Icon (1 to 255)
	Height:      BYTE, // Height (1 byte), Height of Icon (1 to 255)
	ColorCount:  BYTE, // ColorCount (1 byte), Number of colors, either 0 for 24 bit or higher, 2 for monochrome or 16 for 16 color images.
	Reserved:    BYTE, // Reserved (1 byte), Not used (always 0)
	Planes:      WORD, // Planes (2 bytes), always 1
	BitCount:    WORD, // BitCount (2 bytes), number of bits per pixel (1 for monochrome, 4 for 16 colors, 8 for 256 colors, 24 for true colors, 32 for true colors + alpha channel)
	ImageSize:   DWORD, // ImageSize (4 bytes), Length of resource in bytes
	ImageOffset: DWORD, // ImageOffset (4 bytes), start of the image in the file.
}
#assert(size_of(Icon_Directory_Entry) == 16)

@(private = "package")
dump_icon :: proc() {
	icon_path := filepath.clean("misc/emblem.ico")

	fd: ^os.File
	err: os.Error
	ERROR_NONE :: os.ERROR_NONE
	n: int
	po: i64

	fd, err = os.open(icon_path, os.O_RDONLY, 0)
	assert(err == ERROR_NONE)
	if err != ERROR_NONE {panic("os.open")}
	defer os.close(fd)

	ifh: Icon_File_Header
	n, err = os.read_ptr(fd, &ifh, size_of(Icon_File_Header))
	assert(err == ERROR_NONE)
	assert(n == size_of(Icon_File_Header))
	fmt.printfln("ifh: %#v", ifh)

	po, err = os.seek(fd, 0, .Current)
	fmt.printfln("po: %d", po)

	iis := make([]Icon_Directory_Entry, ifh.IconCount)
	defer delete(iis)

	for i in 0 ..< ifh.IconCount {
		n, err = os.read_ptr(fd, &iis[i], size_of(Icon_Directory_Entry))
		assert(err == ERROR_NONE)
		assert(n == size_of(Icon_Directory_Entry))
		//fmt.printfln("ii: %#v", ii)
		po, err = os.seek(fd, 0, .Current)
		fmt.printfln("po: %d", po)
	}

	ii: ^Icon_Directory_Entry = nil
	for i in 0 ..< ifh.IconCount {
		if ii == nil {ii = &iis[i]}
		//fmt.printfln("ii: %#v", &iis[i])
	}
	if ii != nil {
		fmt.printfln("ii: %#v", ii)

		// bytes:= make([]u8, ii.ImageSize)
		// defer delete(bytes)

		os.seek(fd, i64(ii.ImageOffset), .Start)

		bih: BITMAPINFOHEADER // (40 bytes)

		n, err = os.read_ptr(fd, &bih, size_of(BITMAPINFOHEADER))
		assert(err == ERROR_NONE)
		assert(n == size_of(BITMAPINFOHEADER))
		fmt.printfln("read_ptr: %v %v", n, err)
		fmt.printfln("bih: %#v", bih)
		po, err = os.seek(fd, 0, .Current)
		fmt.printfln("po: %d", po)

		rgba: RGBQUAD
		palette: [256][4]u8
		for i in 0 ..< 256 {
			n, err = os.read_ptr(fd, &rgba, size_of(RGBQUAD))
			assert(err == ERROR_NONE)
			assert(n == 4)
			palette[i] = transmute([4]u8)rgba
		}

		po, err = os.seek(fd, 0, .Current)
		fmt.printfln("po: %d", po)

		stride := ((i32((i32(bih.biWidth) * i32(bih.biBitCount)) + 31) & ~i32(31)) >> 3)
		biSizeImage := abs(bih.biHeight) * stride
		fmt.printfln("biSizeImage: %d %d", stride, biSizeImage)

		bytes := make([]u8, biSizeImage)
		defer delete(bytes)

		n, err = os.read(fd, bytes)
		fmt.printfln("bytes: %v", bytes)

		//fmt.printfln("bytes: %v", bytes)
	}
	/*
	po, err = os.seek(fd, 0, 1)
	fmt.printfln("po: %d", po)
	*/
	//bih: BITMAPINFOHEADER // (40 bytes)
}

icon_mask_size :: 32 * 4


// odinfmt: disable

icon_mask_and := [icon_mask_size]u8 {
	0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xC3, 0xFF,
	0xFF, 0xFF, 0x00, 0xFF,
	0xFF, 0xFE, 0x00, 0x7F,
	0xFF, 0xFC, 0x00, 0x1F,
	0xFF, 0xF8, 0x00, 0x0F,
	0xFF, 0xF8, 0x00, 0x0F,
	0xFF, 0xF0, 0x00, 0x07,
	0xFF, 0xF0, 0x00, 0x03,
	0xFF, 0xE0, 0x00, 0x03,
	0xFF, 0xE0, 0x00, 0x01,
	0xFF, 0xE0, 0x00, 0x01,
	0xFF, 0xF0, 0x00, 0x01,
	0xFF, 0xF0, 0x00, 0x00,
	0xFF, 0xF8, 0x00, 0x00,
	0xFF, 0xFC, 0x00, 0x00,
	0xFF, 0xFF, 0x00, 0x00,
	0xFF, 0xFF, 0x80, 0x00,
	0xFF, 0xFF, 0xE0, 0x00,
	0xFF, 0xFF, 0xE0, 0x01,
	0xFF, 0xFF, 0xF0, 0x01,
	0xFF, 0xFF, 0xF0, 0x01,
	0xFF, 0xFF, 0xF0, 0x03,
	0xFF, 0xFF, 0xE0, 0x03,
	0xFF, 0xFF, 0xE0, 0x07,
	0xFF, 0xFF, 0xC0, 0x0F,
	0xFF, 0xFF, 0xC0, 0x0F,
	0xFF, 0xFF, 0x80, 0x1F,
	0xFF, 0xFF, 0x00, 0x7F,
	0xFF, 0xFC, 0x00, 0xFF,
	0xFF, 0xF8, 0x03, 0xFF,
	0xFF, 0xFC, 0x3F, 0xFF,
}

icon_mask_xor := [icon_mask_size]u8 {
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x38, 0x00,
	0x00, 0x00, 0x7C, 0x00,
	0x00, 0x00, 0x7C, 0x00,
	0x00, 0x00, 0x7C, 0x00,
	0x00, 0x00, 0x38, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
}

// odinfmt: enable
