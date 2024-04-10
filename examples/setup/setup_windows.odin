//+private file
//+build windows
package main

import "core:fmt"
import "core:runtime"
//import "core:strings"
import "base:intrinsics"
import "core:os"
import "core:path/filepath"
import win32 "core:sys/windows"

L :: intrinsics.constant_utf16_cstring
wstring :: win32.wstring
wstring_to_utf8 :: win32.wstring_to_utf8
utf8_to_wstring :: win32.utf8_to_wstring

// https://learn.microsoft.com/en-us/windows/win32/shell/app-registration#registering-applications
// https://learn.microsoft.com/en-us/windows/win32/shell/how-to-assign-a-custom-icon-to-a-file-type
// https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/cc144156(v=vs.85)
// https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page

IDI_ICON1 :: 1 // TODO 101

// MAX_KEY_LENGTH :: 255
// MAX_VALUE_NAME :: 16383

show_small_icons := true

command_flag :: enum {
	si,
	mi,
	vi,
	ci,
	icon,
	lc,
}
commands :: bit_set[command_flag]
cmds: commands = {.icon}
add_args_to_commands :: proc() {
	for arg in os.args {
		if len(arg) > 1 && arg[0] == '-' {
			cmd := arg[1:]
			switch cmd {
			case "si":
				cmds += {.si}
			case "mi":
				cmds += {.mi}
			case "vi":
				cmds += {.vi}
			case "ci":
				cmds += {.ci}
			case "icon":
				cmds += {.icon}
			case "lc":
				cmds += {.lc}
			}
		}
	}
}

is_user_interactive :: proc() -> bool {
	isUserNonInteractive := false
	process_window_station := win32.GetProcessWindowStation()
	if process_window_station != nil {
		length_needed: win32.DWORD = 0
		user_object_flags: win32.USEROBJECTFLAGS
		if (win32.GetUserObjectInformationW(win32.HANDLE(process_window_station), .UOI_FLAGS, &user_object_flags, size_of(win32.USEROBJECTFLAGS), &length_needed)) {
			assert(length_needed == size_of(win32.USEROBJECTFLAGS))
			isUserNonInteractive = (user_object_flags.dwFlags & 1) == 0
		}
	}
	return !isUserNonInteractive
}

show_last_error :: proc(caption: string, loc := #caller_location) {
	error_text: [512]win32.WCHAR

	fmt.eprintln(caption)
	last_error := win32.GetLastError()

	error_wstring := wstring(&error_text[0])
	cch := win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM | win32.FORMAT_MESSAGE_IGNORE_INSERTS, nil, last_error, win32.LANGID_NEUTRAL, error_wstring, len(error_text) - 1, nil)
	if (cch != 0) {return}
	error_string, err := wstring_to_utf8(&error_wstring[0], int(cch))
	if err == .None {
		fmt.eprintln(error_string)
	} else {
		fmt.eprintfln("Last error code: %d (0x%8X)", last_error)
	}
}

lcid_to_local_name :: proc(lcid: win32.LCID) -> string {
	wname: [512]win32.WCHAR
	cc := win32.LCIDToLocaleName(lcid, &wname[0], len(wname) - 1, 0)
	if cc != 0 {
		name, err := wstring_to_utf8(&wname[0], int(cc))
		if err == .None {
			return name
		}
	}
	return ""
}

get_language_name :: proc(lang: win32.DWORD, allocator := context.allocator) -> (res: string, hr: int) {
	cchLang: win32.DWORD = 255
	text := make([]u16, cchLang + 1, allocator = context.temp_allocator)
	defer delete(text)
	cchLang = win32.VerLanguageNameW(lang, &text[0], cchLang)
	if cchLang == 0 {
		hr = -3
	} else {
		err: runtime.Allocator_Error
		res, err = wstring_to_utf8(&text[0], int(cchLang), allocator = allocator)
		hr = int(err)
	}
	return
}

get_codepage_and_language :: proc(info: []u8) -> (u16, u16, int) {
	len: win32.UINT
	pcpl: ^[2]u16
	if !win32.VerQueryValueW(&info[0], L("\\VarFileInfo\\Translation"), (^rawptr)(&pcpl), &len) {
		return 0, 0, -1
	}
	if len != size_of([2]u16) {
		return 0, 0, -2
	}
	return pcpl^.y, pcpl^.x, 0
}

query_string_file_info :: proc(info: []u8, cplhex, key: string, allocator := context.allocator) -> (text: string, hr: int) {
	wvalue: wstring
	len: win32.UINT
	cplstr := utf8_to_wstring(fmt.tprintf("\\StringFileInfo\\%s\\%s", cplhex, key))
	if !win32.VerQueryValueW(&info[0], cplstr, (^rawptr)(&wvalue), &len) {
		hr = -7
		return
	}
	err: runtime.Allocator_Error
	text, err = wstring_to_utf8(wvalue, int(len), allocator = allocator)
	hr = int(err)
	return
}

show_file_info :: proc(info: []u8) -> int {
	// Odinified struct of win32.VS_FIXEDFILEINFO for easier decoding
	VS_FIXEDFILEINFO :: struct {
		/* e.g. 0xFEEF04BD */
		dwSignature:      win32.DWORD,
		/* note need to swizzle with .yx */
		dwStrucVersion:   [2]win32.WORD,
		/* note need to swizzle with .yxwz */
		dwFileVersion:    [4]win32.WORD,
		/* note need to swizzle with .yxwz */
		dwProductVersion: [4]win32.WORD,
		/* e.g. 0x3F for version "0.42" */
		dwFileFlagsMask:  win32.VS_FILEFLAGS,
		/* e.g. VS_FF.DEBUG | VS_FF.PRERELEASE */
		dwFileFlags:      win32.VS_FILEFLAGS,
		/* e.g. {VOS = .NT, VOS2 = .WINDOWS32} */
		dwFileOS:         struct {
			VOS:  win32.VOS,
			VOS2: win32.VOS2,
		},
		/* e.g. VFT.DRV */
		dwFileType:       win32.VFT,
		dwFileSubtype:    struct #raw_union {
			DRV:  win32.VFT2_WINDOWS_DRV,
			FONT: win32.VFT2_WINDOWS_FONT,
			VXD:  win32.DWORD,
		},
		dwFileDate:       [2]win32.DWORD,
	}
	assert(size_of(VS_FIXEDFILEINFO) == size_of(win32.VS_FIXEDFILEINFO))
	ffi: ^VS_FIXEDFILEINFO
	len: win32.UINT
	if !win32.VerQueryValueW(&info[0], L("\\"), (^rawptr)(&ffi), &len) {
		show_last_error("VerQueryValue")
		return -5
	}
	if len < size_of(VS_FIXEDFILEINFO) {
		fmt.eprintfln("Too small %d < %d", len, size_of(VS_FIXEDFILEINFO))
		return -6
	}
	fmt.println("[Version Info]")
	fmt.printfln("  %-20s: 0x%X (%s)", "Signature", ffi.dwSignature, "OK" if ffi.dwSignature == win32.VS_FFI_SIGNATURE else "Mismatch")
	fmt.printfln("  %-20s: %v", "Struc Version", ffi.dwStrucVersion.yx)
	fmt.printfln("  %-20s: %v", "File Version", ffi.dwFileVersion.yxwz)
	fmt.printfln("  %-20s: %v", "Product Version", ffi.dwProductVersion.yxwz)
	fmt.printf("  %-20s:", "File Flags Mask")
	for flg in win32.VS_FILEFLAG {if flg in ffi.dwFileFlagsMask {fmt.printf(" %v", flg)}}
	fmt.println()
	fmt.printf("  %-20s:", "File Flags")
	for flg in win32.VS_FILEFLAG {if flg in ffi.dwFileFlags {fmt.printf(" %v", flg)}}
	fmt.println()
	fmt.printfln("  %-20s: %v, %v", "File OS", ffi.dwFileOS.VOS, ffi.dwFileOS.VOS2)
	fmt.printfln("  %-20s: %v", "File Date", transmute(u64)ffi.dwFileDate.yx)
	fmt.printfln("  %-20s: %v", "File Type", ffi.dwFileType)
	#partial switch ffi.dwFileType {
	case .DRV:
		fmt.printfln("File Subtype DRV: %v", ffi.dwFileSubtype.DRV)
	case .FONT:
		fmt.printfln("File Subtype FONT: %v", ffi.dwFileSubtype.FONT)
	case .VXD:
		fmt.printfln("File Subtype VXD: %v", ffi.dwFileSubtype.VXD)
	}

	//fmt.printfln("ffi:\n%v", ffi)
	return 0
}

show_code_page :: proc(cp: win32.CODEPAGE) {
	cpi: win32.CPINFOEXW
	if !win32.GetCPInfoExW(cp, 0, &cpi) {return}
	fmt.printfln("  %-20s: %v", "CodePage", cpi.CodePage)
	fmt.printfln("  %-20s: %s", "CodePageName", wstring(&cpi.CodePageName[0]))
	fmt.printfln("  %-20s: %v", "MaxCharSize", cpi.MaxCharSize)
	fmt.printfln("  %-20s: %d", "DefaultChar", transmute(win32.WCHAR)cpi.DefaultChar)
	fmt.printfln("  %-20s: %d", "UnicodeDefaultChar", cpi.UnicodeDefaultChar)
	fmt.printfln("  %-20s: %v", "LeadByte", cpi.LeadByte)
}

show_string_file_info :: proc(info: []u8, codepage: win32.WORD, langid: win32.WORD) {
	fmt.println("[String File Info]")
	cplhex := fmt.tprintf("%4x%4x", langid, codepage)
	keys := []string{"CompanyName", "FileDescription", "FileVersion", "InternalName", "LegalCopyright", "OriginalFilename", "ProductName", "ProductVersion", "Comments", "GitSha"}
	for key in keys {
		value, err := query_string_file_info(info, cplhex, key, context.temp_allocator)
		if err == 0 {
			fmt.printfln("  %-20s: \"%s\"", key, value)
		}
	}
}

show_code_pages :: proc() {
	cp_i, cp_o := win32.GetConsoleCP(), win32.GetConsoleOutputCP()
	if cp_i == cp_o {
		fmt.println("[Console Code Page]")
		show_code_page(cp_o)
	} else {
		fmt.println("[Console Code Page Input]")
		show_code_page(cp_i)
		fmt.println("[Console Code Page Output]")
		show_code_page(cp_o)
	}
}

show_system_defaults :: proc() {
	fmt.println("[System Default]")
	fmt.printfln("  %-20s: %d", "LangID", win32.GetSystemDefaultLangID())
	fmt.printfln("  %-20s: %d", "LCID", win32.GetSystemDefaultLCID())
	wlocale_name: [512]win32.WCHAR
	cch := win32.GetSystemDefaultLocaleName(wstring(&wlocale_name), len(wlocale_name))
	locale_name, err := wstring_to_utf8(wstring(&wlocale_name), int(cch))
	if err != .None {show_last_error("wstring_to_utf8");return}
	fmt.printfln("  %-20s: \"%s\"", "Locale Name", locale_name)
}

show_system_info :: proc() {
	info: win32.SYSTEM_INFO
	win32.GetSystemInfo(&info)
	fmt.println("[System Info]")
	//fmt.printfln("%#v", info)
	print_key_value("Processor Architecture", info.wProcessorArchitecture)
	print_key_value("Processor Type", info.dwProcessorType)
	print_key_value("Processor Level", info.wProcessorLevel)
	print_key_value("Processor Revision", info.wProcessorRevision)
	print_key_value("Number Of Processors", info.dwNumberOfProcessors)
	print_key_value("Active Processor Mask", info.dwActiveProcessorMask)
	print_key_value("Page Size", info.dwPageSize)
	print_key_value("Minimum Application Address", info.lpMinimumApplicationAddress)
	print_key_value("Maximum Application Address", info.lpMaximumApplicationAddress)
	print_key_value("Allocation Granularity", info.dwAllocationGranularity)
}

ESC :: "\x1B"
CSI :: ESC + "["

rgba :: [4]u8

vt_set_color :: proc(mode: i32, col: rgba) {
	fmt.printf(CSI + "%d;2;%d;%d;%dm", mode, col.b, col.g, col.r)
}

vt_restore_color :: proc() {
	fmt.println(CSI + "0m")
}

print_icon_big :: proc(pixels: []rgba, width, height: i32) {
	block :: "\u2588\u2588" // 2 x full blobk
	i: i32
	for y in 0 ..< height {
		i = y * width
		fg := pixels[i:(i + width)]
		for x in 0 ..< width {
			vt_set_color(38, fg[x])
			fmt.print(block)
		}
		vt_restore_color()
	}
}

print_icon_small :: proc(pixels: []rgba, width, height: i32) {
	block :: "\u2584" // half block
	i: i32
	for y: i32 = 0; y < height; y += 2 {
		i = y * width
		bg := pixels[i:(i + width)]
		i += width
		fg := pixels[i:(i + width)]
		for x in 0 ..< width {
			vt_set_color(48, bg[x])
			vt_set_color(38, fg[x])
			fmt.print(block)
		}
		vt_restore_color()
	}
}

show_icon_info :: proc(icon: win32.HICON) {
	fmt.println("[Icon Info]")
	icon_info: win32.ICONINFOEXW
	icon_info.cbSize = size_of(win32.ICONINFOEXW)
	if !win32.GetIconInfoExW(icon, &icon_info) {
		show_last_error("GetIconInfoExW")
	} else {
		defer {
			if icon_info.hbmMask != nil {win32.DeleteObject(win32.HGDIOBJ(icon_info.hbmMask))}
			if icon_info.hbmColor != nil {win32.DeleteObject(win32.HGDIOBJ(icon_info.hbmColor))}
		}
		if .ci in cmds {
			print_key_value("Icon", icon_info.fIcon)
			print_key_value("Hotspot", icon_info.Hotspot)
			print_key_value("Mask", icon_info.hbmMask)
			print_key_value("Color", icon_info.hbmColor)
			print_key_value("ResID", icon_info.wResID)
			// print_key_value("ModName", icon_info.szModName)
			// print_key_value("ResName", icon_info.szResName)
			fmt.printfln("  %-20s: \"%s\"", "ModName", wstring(&icon_info.szModName))
			fmt.printfln("  %-20s: \"%s\"", "ResName", wstring(&icon_info.szResName))
		}
		if .icon in cmds {
			pixels: []rgba = nil

			if icon_info.hbmColor != nil {
				dc := win32.CreateCompatibleDC(nil)
				defer win32.DeleteDC(dc)
				//std::memset(&Info, 0, sizeof(BITMAPINFO)); //not necessary really..
				old_gdi_obj := win32.SelectObject(dc, win32.HGDIOBJ(icon_info.hbmColor))
				defer win32.SelectObject(dc, old_gdi_obj)

				bmp: win32.BITMAP
				win32.GetObjectW(win32.HANDLE(icon_info.hbmColor), size_of(bmp), &bmp)
				width, height := bmp.bmWidth, bmp.bmHeight

				bmi: win32.BITMAPINFO = {
					bmiHeader =  {
						biSize = size_of(win32.BITMAPINFOHEADER),
						biWidth = width,
						biHeight = -height,
						biPlanes = 1,
						biBitCount = bmp.bmBitsPixel,
						biCompression = win32.BI_RGB,
						biSizeImage = ((u32(width) * u32(bmp.bmBitsPixel) + 31) / 32) * 4 * u32(width),
					},
				}
				pixel_count := bmi.bmiHeader.biSizeImage / size_of(rgba)
				pixels = make([]rgba, pixel_count, context.temp_allocator) // defer delete(pixels)
				hr := win32.GetDIBits(dc, icon_info.hbmColor, 0, win32.UINT(height), &pixels[0], &bmi, win32.DIB_RGB_COLORS)
				if win32.FAILED(hr) {
					show_last_error("GetDIBits")
				} else if has_ansi_terminal_colours {
					if show_small_icons {
						print_icon_small(pixels, width, height)
					} else {
						print_icon_big(pixels, width, height)
					}
				} else {
					fmt.println("ENABLE_VIRTUAL_TERMINAL_PROCESSING not enabled")
				}
			}
		}
	}
}

show_icon :: proc(module: win32.HMODULE, icon_id: int) {
	icon := win32.LoadIconW(win32.HINSTANCE(module), win32.MAKEINTRESOURCEW(icon_id))
	if .mi in cmds {
		print_key_value("Icon", icon)
	}
	if icon == nil {return}
	show_icon_info(icon)
}

get_module_filename :: proc(module: win32.HMODULE) -> string {
	wname: [512]win32.WCHAR
	cc := win32.GetModuleFileNameW(module, &wname[0], len(wname) - 1)
	if cc != 0 {
		name, err := wstring_to_utf8(&wname[0], int(cc))
		if err == .None {
			return name
		}
	}
	return "na"
}

show_module :: proc(path: string) {
	//module := win32.GetModuleHandleW(nil)
	module := win32.LoadLibraryExW(utf8_to_wstring(path), nil, .LOAD_LIBRARY_AS_DATAFILE)
	if module == nil {show_last_error("LoadLibraryExW");return}
	defer {if !win32.FreeLibrary(module) {fmt.eprintln("Unable to free library!")}}
	if .mi in cmds {
		fmt.println("[Module]")
		print_key_value("Module Handle", module)
	}
	show_icon(module, IDI_ICON1)
}

@(private = "package")
setup_windows :: proc() -> int {
	changed := false

	add_args_to_commands()

	if .si in cmds {
		print_key_value("Is User Interactive", is_user_interactive())
	}

	if .mi in cmds {
		module := win32.GetModuleHandleW(nil)
		print_key_value("Module Filename", get_module_filename(module))
	}

	odin_path := filepath.join({ODIN_ROOT, "odin.exe"}, allocator = context.temp_allocator)
	if .vi in cmds {
		odin_path_w := utf8_to_wstring(odin_path)
		info_size := win32.GetFileVersionInfoSizeW(odin_path_w, nil)
		if info_size == 0 {
			fmt.eprintfln("Unable to get file information from %s (0x%X)", odin_path, win32.GetLastError())
			return -1
		}
		info := make([]u8, info_size, allocator = context.temp_allocator)
		if !win32.GetFileVersionInfoW(odin_path_w, 0, info_size, &info[0]) {
			show_last_error("GetFileVersionInfoW")
			return -2
		}

		if show_file_info(info) != 0 {
			show_last_error("show_file_info")
			return -3
		}

		codepage, langid, hr := get_codepage_and_language(info)
		if hr != 0 {
			fmt.eprintfln("get_codepage_and_language (0x%X) %d", win32.GetLastError(), hr)
			return -7
		}

		fmt.printfln("  %-20s: %d (0x%X) %v", "Codepage", codepage, codepage, win32.CODEPAGE(codepage))
		show_code_page(win32.CODEPAGE(codepage))

		{
			fmt.printf("  %-20s: %d (0x%X)", "Language", langid, langid)
			lname, err := get_language_name(u32(langid), allocator = context.temp_allocator)
			if err == 0 {
				fmt.printf(" \"%s\"", lname)
			} else {
				fmt.printf(" language not found: 0x%X %v", langid, err)
			}
			fmt.printfln(" \"%s\"", lcid_to_local_name(u32(langid)))
		}

		if .lc in cmds {
			show_string_file_info(info, codepage, langid)
			show_code_pages()
			show_system_defaults()
		}
		if .si in cmds {
			show_system_info()
		}
	}
	show_module(odin_path)

	// https://ss64.com/nt/syntax-ansi.html
	// https://github.com/Microsoft/Terminal/tree/main/src/tools/ColorTool
	// [HKEY_CURRENT_USER\Console]
	// "VirtualTerminalLevel"=dword:00000001

	//changed = true

	//HICON hicon = LoadImage(NULL, "filename.ico", IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_LOADFROMFILE);

	if changed {
		fmt.println("Notify windows to reload icons...")
		win32.SHChangeNotify(win32.SHCNE_ASSOCCHANGED, win32.SHCNF_IDLIST, nil, nil)
	}

	return 0
}

has_ansi_terminal_colours := false
code_page := win32.CODEPAGE.UTF8

@(init)
init_console :: proc() {

	hnd := win32.GetStdHandle(win32.STD_ERROR_HANDLE)
	mode: win32.DWORD = 0
	if win32.GetConsoleMode(hnd, &mode) {
		if win32.SetConsoleMode(hnd, mode | win32.ENABLE_VIRTUAL_TERMINAL_PROCESSING) {
			has_ansi_terminal_colours = true
		}
	}

	cpi, cpo := win32.GetConsoleCP(), win32.GetConsoleOutputCP()
	if cpi != code_page {
		fmt.printfln("SetConsoleCP(%d)", code_page)
		win32.SetConsoleCP(code_page)
	}
	if cpo != code_page {
		fmt.printfln("SetConsoleOutputCP(%d)", code_page)
		win32.SetConsoleOutputCP(code_page)
	}
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
