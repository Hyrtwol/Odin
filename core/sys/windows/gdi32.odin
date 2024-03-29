// +build windows
package sys_windows

import "core:math/fixed"

foreign import gdi32 "system:Gdi32.lib"

@(default_calling_convention = "system")
foreign gdi32 {
	CreateCompatibleDC :: proc(hdc: HDC) -> HDC ---
	DeleteDC :: proc(hdc: HDC) -> BOOL ---
	CancelDC :: proc(hdc: HDC) -> BOOL ---

	SaveDC :: proc(hdc: HDC) -> INT ---
	RestoreDC :: proc(hdc: HDC, nSavedDC: INT) -> BOOL ---

	GetStockObject :: proc(i: INT) -> HGDIOBJ ---
	SelectObject :: proc(hdc: HDC, h: HGDIOBJ) -> HGDIOBJ ---
	DeleteObject :: proc(ho: HGDIOBJ) -> BOOL ---

	CreateDIBPatternBrush :: proc(h: HGLOBAL, iUsage: UINT) -> HBRUSH ---
	CreateDIBitmap :: proc(hdc: HDC, pbmih: ^BITMAPINFOHEADER, flInit: DWORD, pjBits: VOID, pbmi: ^BITMAPINFO, iUsage: UINT) -> HBITMAP ---
	CreateDIBSection :: proc(hdc: HDC, pbmi: ^BITMAPINFO, usage: UINT, ppvBits: VOID, hSection: HANDLE, offset: DWORD) -> HBITMAP ---
	SetDIBits :: proc(hdc: HDC, hbm: HBITMAP, start: UINT, cLines: UINT, lpBits: VOID, lpbmi: ^BITMAPINFO, ColorUse: UINT) -> INT ---
	GetDIBits :: proc(hdc: HDC, hbm: HBITMAP, start, cLines: UINT, lpvBits: LPVOID, lpbmi: ^BITMAPINFO, usage: UINT) -> INT ---
	SetDIBColorTable :: proc(hdc: HDC, iStart: UINT, cEntries: UINT, prgbq: ^RGBQUAD) -> UINT ---
	GetDIBColorTable :: proc(hdc: HDC, iStart: UINT, cEntries: UINT, prgbq: ^RGBQUAD) -> UINT ---
	StretchDIBits :: proc(hdc: HDC, xDest: INT, yDest: INT, DestWidth: INT, DestHeight: INT, xSrc: INT, ySrc: INT, SrcWidth: INT, SrcHeight: INT, lpBits: VOID, lpbmi: ^BITMAPINFO, iUsage: UINT, rop: DWORD) -> INT ---
	StretchBlt :: proc(hdcDest: HDC, xDest: INT, yDest: INT, wDest: INT, hDest: INT, hdcSrc: HDC, xSrc: INT, ySrc: INT, wSrc: INT, hSrc: INT, rop: DWORD) -> BOOL ---

	SetPixelFormat :: proc(hdc: HDC, format: INT, ppfd: ^PIXELFORMATDESCRIPTOR) -> BOOL ---
	ChoosePixelFormat :: proc(hdc: HDC, ppfd: ^PIXELFORMATDESCRIPTOR) -> INT ---
	DescribePixelFormat :: proc(hdc: HDC, iPixelFormat: INT, nBytes: UINT, ppfd: ^PIXELFORMATDESCRIPTOR) -> INT ---

	SwapBuffers :: proc(hdc: HDC) -> BOOL ---
	PatBlt :: proc(hdc: HDC, x, y, w, h: INT, rop: DWORD) -> BOOL ---
	Rectangle :: proc(hdc: HDC, left, top, right, bottom: INT) -> BOOL ---

	SetBkMode :: proc(hdc: HDC, mode: BKMODE) -> INT ---
	SetBkColor :: proc(hdc: HDC, color: COLORREF) -> COLORREF ---

	CreateFontW :: proc(cHeight, cWidth, cEscapement, cOrientation, cWeight: INT, bItalic, bUnderline, bStrikeOut, iCharSet, iOutPrecision: DWORD, iClipPrecision, iQuality, iPitchAndFamily: DWORD, pszFaceName: LPCWSTR) -> HFONT ---
	TextOutW :: proc(hdc: HDC, x, y: INT, lpString: LPCWSTR, c: INT) -> BOOL ---
	SetTextColor :: proc(hdc: HDC, color: COLORREF) -> COLORREF ---
	GetTextExtentPoint32W :: proc(hdc: HDC, lpString: LPCWSTR, c: INT, psizl: LPSIZE) -> BOOL ---
	GetTextMetricsW :: proc(hdc: HDC, lptm: LPTEXTMETRICW) -> BOOL ---

	CreateSolidBrush :: proc(color: COLORREF) -> HBRUSH ---
	SetDCBrushColor :: proc(hdc: HDC, color: COLORREF) -> COLORREF ---
	GetDCBrushColor :: proc(hdc: HDC) -> COLORREF ---
	SetDCPenColor :: proc(hdc: HDC, color: COLORREF) -> COLORREF ---
	GetDCPenColor :: proc(hdc: HDC) -> COLORREF ---

	GetObjectW :: proc(h: HANDLE, c: INT, pv: LPVOID) -> int ---
	CreateCompatibleBitmap :: proc(hdc: HDC, cx, cy: INT) -> HBITMAP ---
	BitBlt :: proc(hdc: HDC, x, y, cx, cy: INT, hdcSrc: HDC, x1, y1: INT, rop: DWORD) -> BOOL ---

	CreatePalette :: proc(plpal: ^LOGPALETTE) -> HPALETTE ---
	SelectPalette :: proc(hdc: HDC, hPal: HPALETTE, bForceBkgd: BOOL) -> HPALETTE ---
	RealizePalette :: proc(hdc: HDC) -> UINT ---

	RoundRect :: proc(hdc: HDC, left: INT, top: INT, right: INT, bottom: INT, width: INT, height: INT) -> BOOL ---
	SetPixel :: proc(hdc: HDC, x: INT, y: INT, color: COLORREF) -> COLORREF ---

	// same as msimg32.TransparentBlt
	GdiTransparentBlt :: proc(hdcDest: HDC, xoriginDest, yoriginDest, wDest, hDest: INT, hdcSrc: HDC, xoriginSrc, yoriginSrc, wSrc, hSrc: INT, crTransparent: UINT) -> BOOL ---
	// same as msimg32.GradientFill
	GdiGradientFill :: proc(hdc: HDC, pVertex: PTRIVERTEX, nVertex: ULONG, pMesh: PVOID, nCount: ULONG, ulMode: ULONG) -> BOOL ---
	// same as msimg32.AlphaBlend
	GdiAlphaBlend :: proc(hdcDest: HDC, xoriginDest, yoriginDest, wDest, hDest: INT, hdcSrc: HDC, xoriginSrc, yoriginSrc, wSrc, hSrc: INT, ftn: BLENDFUNCTION) -> BOOL ---

}

RGB :: #force_inline proc "contextless" (r, g, b: u8) -> COLORREF {
	return transmute(COLORREF)[4]u8{r, g, b, 0}
}

FXPT2DOT30 :: distinct fixed.Fixed(i32, 30)

CIEXYZ :: struct {
	ciexyzX: FXPT2DOT30,
	ciexyzY: FXPT2DOT30,
	ciexyzZ: FXPT2DOT30,
}

CIEXYZTRIPLE :: struct {
	ciexyzRed:   CIEXYZ,
	ciexyzGreen: CIEXYZ,
	ciexyzBlue:  CIEXYZ,
}

// https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header
BITMAPV5HEADER :: struct {
	bV5Size:          DWORD,
	bV5Width:         LONG,
	bV5Height:        LONG,
	bV5Planes:        WORD,
	bV5BitCount:      WORD,
	bV5Compression:   DWORD,
	bV5SizeImage:     DWORD,
	bV5XPelsPerMeter: LONG,
	bV5YPelsPerMeter: LONG,
	bV5ClrUsed:       DWORD,
	bV5ClrImportant:  DWORD,
	bV5RedMask:       DWORD,
	bV5GreenMask:     DWORD,
	bV5BlueMask:      DWORD,
	bV5AlphaMask:     DWORD,
	bV5CSType:        DWORD,
	bV5Endpoints:     CIEXYZTRIPLE,
	bV5GammaRed:      DWORD,
	bV5GammaGreen:    DWORD,
	bV5GammaBlue:     DWORD,
	bV5Intent:        DWORD,
	bV5ProfileData:   DWORD,
	bV5ProfileSize:   DWORD,
	bV5Reserved:      DWORD,
}

PALETTEENTRY :: struct {
	peRed:   BYTE,
	peGreen: BYTE,
	peBlue:  BYTE,
	peFlags: BYTE,
}

LOGPALETTE :: struct {
	palVersion:    WORD,
	palNumEntries: WORD,
	palPalEntry:   []PALETTEENTRY,
}

BKMODE :: enum {
	TRANSPARENT = 1,
	OPAQUE      = 2,
}

ICONINFOEXW :: struct {
	cbSize: DWORD,
	fIcon: BOOL,
	Hotspot: [2]DWORD,
	hbmMask: HBITMAP,
	hbmColor: HBITMAP,
	wResID: WORD,
	szModName: [MAX_PATH]WCHAR,
	szResName: [MAX_PATH]WCHAR,
}
PICONINFOEXW :: ^ICONINFOEXW

AC_SRC_OVER :: 0x00
AC_SRC_ALPHA :: 0x01

TransparentBlt :: GdiTransparentBlt
GradientFill :: GdiGradientFill
AlphaBlend :: GdiAlphaBlend

COLOR16 :: USHORT
TRIVERTEX :: struct {
	x, y: LONG,
	Red, Green, Blue, Alpha: COLOR16,
  }
PTRIVERTEX :: ^TRIVERTEX

GRADIENT_TRIANGLE :: struct {
	Vertex1, Vertex2, Vertex3: ULONG,
}
PGRADIENT_TRIANGLE :: ^GRADIENT_TRIANGLE

GRADIENT_RECT :: struct
{
    UpperLeft, LowerRight: ULONG,
}
PGRADIENT_RECT :: ^GRADIENT_RECT


BLENDFUNCTION :: struct  {
	BlendOp, BlendFlags, SourceConstantAlpha, AlphaFormat: BYTE
}
