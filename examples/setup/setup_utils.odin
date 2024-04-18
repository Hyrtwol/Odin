//+private file
package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "base:intrinsics"

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
TIconFileHeader :: struct #packed {
	// (6 bytes)
	Reserved:  WORD, // Reserved (2 bytes), always 0
	IconType:  WORD, // IconType (2 bytes), if the image is an icon it�s 1, for cursors the value is 2.
	IconCount: WORD, // IconCount (2 bytes), number of icons in this file.
}

TIconInfo :: struct #packed {
	// (16 bytes)
	Width:       BYTE, // (1 byte), Width of Icon (1 to 255)
	Height:      BYTE, // Height (1 byte), Height of Icon (1 to 255)
	ColorCount:  BYTE, // ColorCount (1 byte), Number of colors, either 0 for 24 bit or higher, 2 for monochrome or 16 for 16 color images.
	Reserved:    BYTE, // Reserved (1 byte), Not used (always 0)
	Planes:      WORD, // Planes (2 bytes), always 1
	BitCount:    WORD, // BitCount (2 bytes), number of bits per pixel (1 for monochrome, 4 for 16 colors, 8 for 256 colors, 24 for true colors, 32 for true colors + alpha channel)
	ImageSize:   DWORD, // ImageSize (4 bytes), Length of resource in bytes
	ImageOffset: DWORD, // ImageOffset (4 bytes), start of the image in the file.
}

/*
    src.ReadBuffer(IconFileHeader, SizeOf(TIconFileHeader));
    WriteIconFileHeader(IconFileHeader);

    src.ReadBuffer(IconInfo, SizeOf(TIconInfo));
    WriteIconInfoHeader(IconInfo);

    src.ReadBuffer(bmiHeader, SizeOf(TBitmapInfoHeader));
    WriteBitmapInfoHeader(bmiHeader);

    {Memo1.Lines.Add('TBitmapFileHeader');
      Memo1.Lines.Add('Header.bfType: ' + IntToStr(BMP.Header.bfType));
      Memo1.Lines.Add('Header.bfSize: ' + IntToStr(BMP.Header.bfSize));
      Memo1.Lines.Add('Header.bfReserved1: ' + IntToStr(BMP.Header.bfReserved1));
      Memo1.Lines.Add('Header.bfReserved2: ' + IntToStr(BMP.Header.bfReserved2));
    Memo1.Lines.Add('Header.bfOffBits: ' + IntToStr(BMP.Header.bfOffBits));}

    //Pal.palVersion := $300;
    palNumEntries := 1 shl bmiHeader.biBitCount;
    src.ReadBuffer(Pal, palNumEntries * 4);
*/

@(private = "package")
dump_icon :: proc() {
	icon_path := filepath.clean("misc/emblem.ico")

	//ii: TIconInfo

	fd: os.Handle
	err: os.Errno
	n: int
	po: i64

	fd, err = os.open(icon_path, os.O_RDONLY, 0)
	assert(err == 0)
	if err != 0 {panic("os.open")}
	defer os.close(fd)

	ifh: TIconFileHeader
	n, err = os.read_ptr(fd, &ifh, size_of(TIconFileHeader))
	assert(err == 0)
	assert(n == size_of(TIconFileHeader))
	fmt.printfln("ifh: %#v", ifh)

	po, err = os.seek(fd, 0, 1)
	fmt.printfln("po: %d", po)

	iis := make([]TIconInfo, ifh.IconCount)
	defer delete(iis)

	for i in 0 ..< ifh.IconCount {
		n, err = os.read_ptr(fd, &iis[i], size_of(TIconInfo))
		assert(err == 0)
		assert(n == size_of(TIconInfo))
		//fmt.printfln("ii: %#v", ii)
		po, err = os.seek(fd, 0, 1)
		fmt.printfln("po: %d", po)
	}

	ii: ^TIconInfo = nil
	for i in 0 ..< ifh.IconCount {
		if ii == nil {ii = &iis[i]}
		//fmt.printfln("ii: %#v", &iis[i])
	}
	if ii != nil {
		fmt.printfln("ii: %#v", ii)

		// bytes:= make([]u8, ii.ImageSize)
		// defer delete(bytes)

		os.seek(fd, i64(ii.ImageOffset), 0)

		bih: BITMAPINFOHEADER // (40 bytes)

		n, err = os.read_ptr(fd, &bih, size_of(BITMAPINFOHEADER))
		assert(err == 0)
		assert(n == size_of(BITMAPINFOHEADER))
		fmt.printfln("read_ptr: %v %v", n, err)
		fmt.printfln("bih: %#v", bih)
		po, err = os.seek(fd, 0, 1)
		fmt.printfln("po: %d", po)

		rgba: RGBQUAD
		palette: [256][4]u8
		for i in 0 ..< 256 {
			n, err = os.read_ptr(fd, &rgba, size_of(RGBQUAD))
			assert(err == 0)
			assert(n == 4)
			palette[i] = {u8(rgba.rgbRed), u8(rgba.rgbGreen), u8(rgba.rgbBlue), u8(rgba.rgbReserved)}
			//fmt.printfln("rgb[%3d]: %v", i, palette[i])
		}

		po, err = os.seek(fd, 0, 1)
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


// odinfmt: disable

_andMaskIcon32 := [?]u8 {
	0xFF, 0xFF, 0xFF, 0xFF,   // line 1
	0xFF, 0xFF, 0xC3, 0xFF,   // line 2
	0xFF, 0xFF, 0x00, 0xFF,   // line 3
	0xFF, 0xFE, 0x00, 0x7F,   // line 4
	0xFF, 0xFC, 0x00, 0x1F,   // line 5
	0xFF, 0xF8, 0x00, 0x0F,   // line 6
	0xFF, 0xF8, 0x00, 0x0F,   // line 7
	0xFF, 0xF0, 0x00, 0x07,   // line 8
	0xFF, 0xF0, 0x00, 0x03,   // line 9
	0xFF, 0xE0, 0x00, 0x03,   // line 10
	0xFF, 0xE0, 0x00, 0x01,   // line 11
	0xFF, 0xE0, 0x00, 0x01,   // line 12
	0xFF, 0xF0, 0x00, 0x01,   // line 13
	0xFF, 0xF0, 0x00, 0x00,   // line 14
	0xFF, 0xF8, 0x00, 0x00,   // line 15
	0xFF, 0xFC, 0x00, 0x00,   // line 16
	0xFF, 0xFF, 0x00, 0x00,   // line 17
	0xFF, 0xFF, 0x80, 0x00,   // line 18
	0xFF, 0xFF, 0xE0, 0x00,   // line 19
	0xFF, 0xFF, 0xE0, 0x01,   // line 20
	0xFF, 0xFF, 0xF0, 0x01,   // line 21
	0xFF, 0xFF, 0xF0, 0x01,   // line 22
	0xFF, 0xFF, 0xF0, 0x03,   // line 23
	0xFF, 0xFF, 0xE0, 0x03,   // line 24
	0xFF, 0xFF, 0xE0, 0x07,   // line 25
	0xFF, 0xFF, 0xC0, 0x0F,   // line 26
	0xFF, 0xFF, 0xC0, 0x0F,   // line 27
	0xFF, 0xFF, 0x80, 0x1F,   // line 28
	0xFF, 0xFF, 0x00, 0x7F,   // line 29
	0xFF, 0xFC, 0x00, 0xFF,   // line 30
	0xFF, 0xF8, 0x03, 0xFF,   // line 31
	0xFF, 0xFC, 0x3F, 0xFF,   // line 32
}

_xorMaskIcon32 := [?]u8 {
	0x00, 0x00, 0x00, 0x00,   // line 1
	0x00, 0x00, 0x00, 0x00,   // line 2
	0x00, 0x00, 0x00, 0x00,   // line 3
	0x00, 0x00, 0x00, 0x00,   // line 4
	0x00, 0x00, 0x00, 0x00,   // line 5
	0x00, 0x00, 0x00, 0x00,   // line 6
	0x00, 0x00, 0x00, 0x00,   // line 7
	0x00, 0x00, 0x38, 0x00,   // line 8
	0x00, 0x00, 0x7C, 0x00,   // line 9
	0x00, 0x00, 0x7C, 0x00,   // line 10
	0x00, 0x00, 0x7C, 0x00,   // line 11
	0x00, 0x00, 0x38, 0x00,   // line 12
	0x00, 0x00, 0x00, 0x00,   // line 13
	0x00, 0x00, 0x00, 0x00,   // line 14
	0x00, 0x00, 0x00, 0x00,   // line 15
	0x00, 0x00, 0x00, 0x00,   // line 16
	0x00, 0x00, 0x00, 0x00,   // line 17
	0x00, 0x00, 0x00, 0x00,   // line 18
	0x00, 0x00, 0x00, 0x00,   // line 19
	0x00, 0x00, 0x00, 0x00,   // line 20
	0x00, 0x00, 0x00, 0x00,   // line 21
	0x00, 0x00, 0x00, 0x00,   // line 22
	0x00, 0x00, 0x00, 0x00,   // line 23
	0x00, 0x00, 0x00, 0x00,   // line 24
	0x00, 0x00, 0x00, 0x00,   // line 25
	0x00, 0x00, 0x00, 0x00,   // line 26
	0x00, 0x00, 0x00, 0x00,   // line 27
	0x00, 0x00, 0x00, 0x00,   // line 28
	0x00, 0x00, 0x00, 0x00,   // line 29
	0x00, 0x00, 0x00, 0x00,   // line 30
	0x00, 0x00, 0x00, 0x00,   // line 31
	0x00, 0x00, 0x00, 0x00,   // line 32
}

// odinfmt: enable
