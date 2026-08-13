// PCX, PiCture eXchange
// - [pcx](https://en.wikipedia.org/wiki/PCX)
// - [pcx.h](https://gist.github.com/martincohen/62e23219a5940d812112)
// - [PcxReader.cs](https://github.com/warrengalyen/ImageFormats/blob/master/ImageFormats/PcxReader.cs)
package pcx

// The fixed header field valued 0x0A.
PCX_MAGIC :: 0xA
// Control byte 0xC before the palette.
PAL_MAGIC :: 0xC

PCXHeader :: struct {
	// The fixed header field valued at a hexadecimal 0x0A (= 10 in decimal).
	id:             u8,
	// The version number referring to the Paintbrush software release, which might be:
	// * 0 PC Paintbrush version 2.5 using a fixed EGA palette
	// * 2 PC Paintbrush version 2.8 using a modifiable EGA palette
	// * 3 PC Paintbrush version 2.8 using no palette
	// * 4 PC Paintbrush for Windows
	// * 5 PC Paintbrush version 3.0, including 24-bit images
	version:        u8,
	// The method used for encoding the image data. Can be:
	// * 0 No encoding (rarely used)
	// * 1 Run-length encoding (RLE)
	encoding:       u8,
	// The number of bits constituting one plane. Most often 1, 2, 4 or 8.
	bits_per_px:    u8,
	// The minimum co-ordinate of the image position.
	min:            [2]i16,
	// The maximum co-ordinate of the image position.
	max:            [2]i16,
	// The image resolution in DPI.
	res:            [2]i16,
	// The EGA palette for 16-color images.
	pal:            [16]PCXColor,
	// The first reserved field, usually set to zero.
	_reserved_1:    u8,
	// The number of color planes constituting the pixel data. Mostly chosen to be 1, 3, or 4.
	planes:         u8,
	// The number of bytes of one color plane representing a single scan line.
	bytes_per_line: i16,
	// The mode in which to construe the palette:
	// * 1 The palette contains monochrome or color information
	// * 2 The palette contains grayscale information
	palette_type:   i16,
	// The resolution of the source system's screen.
	screen_size:    [2]i16,
	// The second reserved field, intended for future extensions, and usually set to zero bytes.
	_reserved_2:    [54]u8,
}

PCXColor :: [3]u8

PCXPalette :: [256]PCXColor

PCX :: struct {
	header:     ^PCXHeader,
	data_begin: ^u8,
	palette:    ^PCXPalette,
	size:       u32,
	w:          u16,
	pitch:      u16,
	h:          u16,
	bpp:        u16,
}

/*
// PCX pcx_open(u8 *buffer, u32 size)
// pcx_open :: proc(buffer: ^u8, size: u32) -> PCX {
    assert(size >= sizeof(PCXHeader));
    PCX pcx = {0};
    pcx.header = (PCXHeader*)buffer;
    // PCX header control byte 0x0a.
    assert(pcx.header->id == 0x0a);
    // Encoding must be RLE.
    assert(pcx.header->encoding == 1);
    // Only 8-bit format is supported.
    assert(pcx.header->bits_per_px == 8);

    assert(pcx.header->x_max > pcx.header->x_min);
    assert(pcx.header->y_max > pcx.header->y_min);

    pcx.w = pcx.header->x_max - pcx.header->x_min + 1;
    pcx.h = pcx.header->y_max - pcx.header->y_min + 1;
    pcx.bpp = 8 / pcx.header->bits_per_px;
    pcx.pitch = pcx.header->bytes_per_line * pcx.header->planes * pcx.bpp;

    // No padding allowed.
    assert((pcx.pitch - pcx.w) == 0);

    pcx.size = pcx.w * pcx.h * pcx.bpp;
    pcx.data_begin = (u8*)(pcx.header + 1);

    u8 *palette = buffer + size - sizeof(PCXPalette) - 1;
    // Control byte 0xC before the palette.
    assert(*palette == 0xC);
    pcx.palette = (PCXPalette*)(palette + 1);

    return pcx;
}
*/

/*
// void pcx_decode(PCX *pcx, u8 *buffer)
// pcx_decode :: proc(pcx: ^PCX, buffer: ^u8) {
    u8 *wit = buffer;
    u8 *rit = pcx->data_begin;

    u8 rc;
    while ((wit - buffer) < (s32)pcx->size)
    {
        if ((*rit & 0xC0) == 0xC0)
        {
            rc = *rit & 0x3F;
            rit++;
            assert(rit != (u8*)pcx->palette);
            do {
                *wit++ = *rit;
            } while (--rc);
            rit++;
        }
        else
        {
            *wit++ = *rit++;
        }
    }
    assert((wit - buffer) == (s32)pcx->size);
}
*/
