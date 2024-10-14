//private file
#+build windows
package main

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import win32 "core:sys/windows"

L :: intrinsics.constant_utf16_cstring
wstring :: win32.wstring
wstring_to_utf8 :: win32.wstring_to_utf8
utf8_to_wstring :: win32.utf8_to_wstring
LSTATUS :: win32.LSTATUS
LSUCCESS :: LSTATUS(win32.ERROR_SUCCESS)

BYTE :: win32.BYTE
WORD :: win32.WORD
DWORD :: win32.DWORD
LONG :: win32.LONG
RGBQUAD :: win32.RGBQUAD
BITMAPINFOHEADER :: win32.BITMAPINFOHEADER

_Path_Separator :: '\\'
_Path_Separator_Str :: "\\"
_Path_List_Separator :: ';'
_Path_List_Separator_Str :: ";"

// https://learn.microsoft.com/en-us/windows/win32/sysinfo/enumerating-registry-subkeys
MAX_KEY_LENGTH: win32.DWORD : 255
MAX_VALUE_NAME: win32.DWORD : 16383

// https://learn.microsoft.com/en-us/windows/win32/shell/app-registration#registering-applications
// https://learn.microsoft.com/en-us/windows/win32/shell/how-to-assign-a-custom-icon-to-a-file-type
// https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/cc144156(v=vs.85)
// https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page
// https://learn.microsoft.com/en-us/windows/win32/sysinfo/getting-system-information

IDI_ICON1 :: 101
IDI_ICON2 :: 102

terminal_color_flag :: enum {
	STD_OUTPUT,
	STD_ERROR,
}
terminal_colors :: bit_set[terminal_color_flag]
has_terminal_colors: terminal_colors = {}
wanted_code_page := win32.CODEPAGE.UTF8

option_flag :: enum u8 {
	sys_info,
	module_info,
	version_info,
	icon_info,
	icon,
	language,
	environment_variables,
	show_small_icons,
	show_big_icons,
}
option_flags :: bit_set[option_flag]
options: option_flags = {.icon, .show_small_icons}
all: u16 = max(u16)

add_args_to_commands :: proc() {
	for arg in os.args {
		if len(arg) > 1 && arg[0] == '-' {
			cmd := arg[1:]
			switch cmd {
			case "si":
				options += {.sys_info}
			case "mi":
				options += {.module_info}
			case "vi":
				options += {.version_info}
			case "ci":
				options += {.icon_info}
			case "icon":
				options += {.icon}
			case "lc":
				options += {.environment_variables}
			case "ev":
				options += {.language}
			case "all":
				options = transmute(option_flags)all
			}
		}
	}
}

is_user_interactive :: proc() -> bool {
	is_User_non_interactive := false
	process_window_station := win32.GetProcessWindowStation()
	if process_window_station != nil {
		length_needed: win32.DWORD = 0
		user_object_flags: win32.USEROBJECTFLAGS
		if win32.GetUserObjectInformationW(win32.HANDLE(process_window_station), .UOI_FLAGS, &user_object_flags, size_of(win32.USEROBJECTFLAGS), &length_needed) {
			assert(length_needed == size_of(win32.USEROBJECTFLAGS))
			is_User_non_interactive = (user_object_flags.dwFlags & 1) == 0
		}
	}
	return !is_User_non_interactive
}

LANGID_NEUTRAL := win32.MAKELANGID(win32.LANG_NEUTRAL, win32.SUBLANG_DEFAULT)

show_last_error :: proc(caption: string, loc := #caller_location) {
	fmt.eprintln(caption)
	last_error := win32.GetLastError()
	error_text: [512]win32.WCHAR
	cch := win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM | win32.FORMAT_MESSAGE_IGNORE_INSERTS, nil, last_error, LANGID_NEUTRAL, &error_text[0], len(error_text) - 1, nil)
	if cch > 0 {
		error_string, err := wstring_to_utf8(&error_text[0], int(cch))
		if err == .None {
			fmt.eprintln(error_string)
			return
		}
	}
	fmt.eprintfln("Last error code: %d (0x%8X)", last_error)
}

lcid_to_local_name :: proc(lcid: win32.LCID) -> string {
	wc: [512]win32.WCHAR
	cch := win32.LCIDToLocaleName(lcid, &wc[0], len(wc) - 1, 0)
	if cch != 0 {
		name, err := wstring_to_utf8(&wc[0], int(cch))
		if err == .None {
			return name
		}
	}
	return ""
}

get_language_name :: proc(lang: win32.DWORD, allocator := context.allocator) -> (res: string, hr: int) {
	cch: win32.DWORD = 255
	text := make([]u16, cch + 1, allocator = context.temp_allocator)
	cch = win32.VerLanguageNameW(lang, &text[0], cch)
	if cch == 0 {
		fmt.eprintfln("VerLanguageNameW: %0h %d", lang, cch)
		hr = -3
	} else {
		err: runtime.Allocator_Error
		res, err = wstring_to_utf8(&text[0], int(cch), allocator = allocator)
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
	wtext: wstring
	cch: win32.UINT
	cplstr := utf8_to_wstring(fmt.tprintf("\\StringFileInfo\\%s\\%s", cplhex, key))
	if !win32.VerQueryValueW(&info[0], cplstr, (^rawptr)(&wtext), &cch) {
		hr = -7
		return
	}
	err: runtime.Allocator_Error
	text, err = wstring_to_utf8(wtext, int(cch), allocator = allocator)
	hr = int(err)
	return
}

show_file_info :: proc(info: []u8) -> int {
	// Odinified struct of win32.VS_FIXEDFILEINFO for easier decoding
	VS_FIXEDFILEINFO :: struct {
		/* e.g. 0xFEEF04BD */
		dwSignature:      win32.DWORD,
		/* note need to swizzle with .yx */
		dwStructVersion:  [2]win32.WORD,
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
	fmt.printfln("  %-20s: %v", "Struct Version", ffi.dwStructVersion.yx)
	fmt.printfln("  %-20s: %v", "File Version", ffi.dwFileVersion.yxwz)
	fmt.printfln("  %-20s: %v", "Product Version", ffi.dwProductVersion.yxwz)
	fmt.printfln("  %-20s: %v", "File Flags Mask", ffi.dwFileFlagsMask)
	fmt.printfln("  %-20s: %v", "File Flags", ffi.dwFileFlags)
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
	keys := []string{"CompanyName", "FileDescription", "FileVersion", "InternalName", "LegalCopyright", "OriginalFilename", "ProductName", "ProductVersion", "Comments", "GitSha", "NightlyBuild"}
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

print_language :: proc(key: string, #any_int langid: int) {
	fmt.printf("  %-20s: %d (0x%X)", key, langid, langid)
	language_name, err := get_language_name(u32(langid), allocator = context.temp_allocator)
	if err == 0 {
		fmt.printf(" \"%s\"", language_name)
	} else {
		fmt.printf(" language not found: 0x%X %v", langid, err)
	}
	fmt.printfln(" \"%s\"", lcid_to_local_name(u32(langid)))
}

show_system_defaults :: proc() {
	fmt.println("[System Default]")
	print_language("LCID", win32.GetSystemDefaultLCID())
	print_language("LangID", win32.GetSystemDefaultLangID())

	w: [512]win32.WCHAR
	cch := win32.GetSystemDefaultLocaleName(wstring(&w), len(w))
	locale_name, err := wstring_to_utf8(wstring(&w), int(cch))
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

CHECK_OK :: "👍"
CHECK_FAIL :: "👎"

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
	block :: "\u2588\u2588" // 2 x full block
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
		if .icon_info in options {
			print_key_value("Icon", icon_info.fIcon)
			print_key_value("Hotspot", [2]win32.DWORD{icon_info.xHotspot, icon_info.yHotspot})
			print_key_value("Mask", icon_info.hbmMask)
			print_key_value("Color", icon_info.hbmColor)
			print_key_value("ResID", icon_info.wResID)
			// print_key_value("ModName", icon_info.szModName)
			// print_key_value("ResName", icon_info.szResName)
			fmt.printfln("  %-20s: \"%s\"", "ModName", wstring(&icon_info.szModName))
			fmt.printfln("  %-20s: \"%s\"", "ResName", wstring(&icon_info.szResName))
		}
		if .icon in options {
			pixels: []rgba = nil

			if icon_info.hbmColor != nil {
				dc := win32.CreateCompatibleDC(nil)
				defer win32.DeleteDC(dc)
				old_gdi_obj := win32.SelectObject(dc, win32.HGDIOBJ(icon_info.hbmColor))
				defer win32.SelectObject(dc, old_gdi_obj)

				bmp: win32.BITMAP
				win32.GetObjectW(win32.HANDLE(icon_info.hbmColor), size_of(bmp), &bmp)
				width, height := bmp.bmWidth, bmp.bmHeight

				bmi: win32.BITMAPINFO = {
					bmiHeader = {
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
				} else if .STD_OUTPUT in has_terminal_colors {
					if .show_small_icons in options {
						print_icon_small(pixels, width, height)
					} else if .show_big_icons in options {
						print_icon_big(pixels, width, height)
					}
				} else {
					fmt.println("ENABLE_VIRTUAL_TERMINAL_PROCESSING not enabled")
				}
			}
		}
	}
}

show_icon :: proc(module: win32.HMODULE, icon_id: int, icon_size: i32 = 16) {
	hResource := win32.FindResourceW(module, win32.MAKEINTRESOURCEW(icon_id), win32.RT_GROUP_ICON)
	if hResource == nil {show_last_error("FindResource");return}
	hMem := win32.LoadResource(module, hResource)
	lpResource := win32.LockResource(hMem)
	nID := win32.LookupIconIdFromDirectoryEx(win32.PBYTE(lpResource), true, icon_size, icon_size, win32.LR_DEFAULTCOLOR)
	hResource = win32.FindResourceW(module, win32.MAKEINTRESOURCEW(nID), win32.MAKEINTRESOURCEW(uintptr(win32.RT_ICON)))
	if hResource == nil {show_last_error("FindResource");return}
	hMem = win32.LoadResource(module, hResource)
	lpResource = win32.LockResource(hMem)
	icon := win32.CreateIconFromResourceEx(win32.PBYTE(lpResource), win32.SizeofResource(module, hResource), true, 0x00030000, icon_size, icon_size, win32.LR_DEFAULTCOLOR)
	if icon == nil {show_last_error("CreateIconFromResourceEx");return}

	if .module_info in options {
		print_key_value("Icon", icon)
	}
	show_icon_info(icon)
}

get_module_filename :: proc(module: win32.HMODULE) -> string {
	w: [512]win32.WCHAR
	cch := win32.GetModuleFileNameW(module, &w[0], len(w) - 1)
	if cch != 0 {
		name, err := wstring_to_utf8(&w[0], int(cch))
		if err == .None {
			return name
		}
	}
	return ""
}

show_module :: proc(path: string) {
	//module := win32.GetModuleHandleW(nil)
	module := win32.LoadLibraryExW(utf8_to_wstring(path), nil, {.LOAD_LIBRARY_AS_DATAFILE})
	if module == nil {show_last_error("LoadLibraryExW");return}
	defer {if !win32.FreeLibrary(module) {fmt.eprintln("Unable to free library!")}}
	if .module_info in options {
		fmt.println("[Module]")
		print_key_value("Module Handle", module)
	}
	show_icon(module, IDI_ICON1)
}

query_key :: proc(hKey: win32.HKEY) {
	err: LSTATUS = 0

	rq: reg_query
	err = reg_query_info_key(hKey, &rq)
	if err != 0 {return}

	// Enumerate the subkeys, until RegEnumKeyEx fails.
	if rq.cSubKeys > 0 {
		fmt.printf("\nNumber of subkeys: %d\n", rq.cSubKeys)

		wchKey: [MAX_KEY_LENGTH]win32.WCHAR // buffer for subkey name

		for i in 0 ..< rq.cSubKeys {
			cbName := MAX_VALUE_NAME
			ftLastWriteTime: win32.FILETIME
			err = win32.RegEnumKeyExW(hKey, i, &wchKey[0], &cbName, nil, nil, nil, &ftLastWriteTime)
			if err == 0 {
				name, err := wstring_to_utf8(&wchKey[0], int(cbName))
				if err == .None {
					fmt.printfln("(%d) Key '%s' ????", i + 1, name)
				}
			}
		}
	}

	// Enumerate the key values.
	if rq.cValues > 0 {
		fmt.printf("\nNumber of values: %d\n", rq.cValues)

		wchValue: [MAX_VALUE_NAME]win32.WCHAR
		cchValue: win32.DWORD

		for i in 0 ..< rq.cValues {
			cchValue = MAX_VALUE_NAME
			err = win32.RegEnumValueW(hKey, i, &wchValue[0], &cchValue, nil, nil, nil, nil)

			if err == 0 {
				if cchValue != 0 {
					name, err := wstring_to_utf8(&wchValue[0], int(cchValue))
					if err == .None {
						fmt.printfln("(%d) '%s'", i + 1, name)
					}
				}
			}
		}
	}
}

reg_open_key :: proc(hkey: win32.HKEY, sub_key: string, options: win32.DWORD = 0, sam_desired: win32.REGSAM = win32.KEY_READ) -> (hkey_result: win32.HKEY, err: i32) {
	err = win32.RegOpenKeyExW(hkey, utf8_to_wstring(sub_key), options, sam_desired, &hkey_result)
	if err != 0 {show_last_error(fmt.tprintf("RegOpenKeyExW %s %d", sub_key, err))}
	return
}

reg_query :: struct {
	cbName:               win32.DWORD, // size of name string
	achClass:             [win32.MAX_PATH]win32.WCHAR, // buffer for class name
	cchClassName:         win32.DWORD, // size of class string (win32.MAX_PATH)
	cSubKeys:             win32.DWORD, // number of subkeys
	cbMaxSubKey:          win32.DWORD, // longest subkey size
	cchMaxClass:          win32.DWORD, // longest class string
	cValues:              win32.DWORD, // number of values for key
	cchMaxValue:          win32.DWORD, // longest value name
	cbMaxValueData:       win32.DWORD, // longest value data
	cbSecurityDescriptor: win32.DWORD, // size of security descriptor
	ftLastWriteTime:      win32.FILETIME, // last write time
}

reg_query_info_key :: proc(hKey: win32.HKEY, rq: ^reg_query) -> i32 {
	rq.cchClassName = u32(win32.MAX_PATH)
	err := win32.RegQueryInfoKeyW(
		hKey, // key handle
		&rq.achClass[0], // buffer for class name
		&rq.cchClassName, // size of class string
		nil, // reserved
		&rq.cSubKeys, // number of subkeys
		&rq.cbMaxSubKey, // longest subkey size
		&rq.cchMaxClass, // longest class string
		&rq.cValues, // number of values for this key
		&rq.cchMaxValue, // longest value name
		&rq.cbMaxValueData, // longest value data
		&rq.cbSecurityDescriptor, // security descriptor
		&rq.ftLastWriteTime, // last write time
	)
	if err != 0 {show_last_error("reg_query_info_key")}
	return err
}

reg_enum_key :: proc(hKey: win32.HKEY, dwIndex: win32.DWORD, allocator := context.temp_allocator) -> (name: string, err: i32) {
	wchKey: [MAX_VALUE_NAME]win32.WCHAR // buffer for subkey name
	cbName := MAX_VALUE_NAME
	ftLastWriteTime: win32.FILETIME
	err = win32.RegEnumKeyExW(hKey, dwIndex, &wchKey[0], &cbName, nil, nil, nil, &ftLastWriteTime)
	if err == 0 {
		aerr: runtime.Allocator_Error
		name, aerr = wstring_to_utf8(&wchKey[0], int(cbName))
		err = i32(aerr)
	}
	if err != 0 {show_last_error("reg_enum_key")}
	return
}

reg_enum_value :: proc(hKey: win32.HKEY, dwIndex: win32.DWORD, allocator := context.temp_allocator) -> (key, value: string, err: i32) {
	//ERROR_MORE_DATA :: i32(os.ERROR_MORE_DATA)
	wchValue: [MAX_VALUE_NAME]win32.WCHAR
	cchValue := MAX_VALUE_NAME
	type: win32.DWORD = 0
	//data: win32.LPBYTE
	cbData: win32.DWORD = 1000
	data := make([]win32.BYTE, cbData, context.temp_allocator)
	//data: [cbData]win32.BYTE
	err = win32.RegEnumValueW(hKey, dwIndex, &wchValue[0], &cchValue, nil, &type, &data[0], &cbData)
	if err != 0 {
		fmt.printfln("cbData=%d type=%d err=%d", cbData, type, err)
		show_last_error("RegEnumValueW")
		return
	}
	if cchValue > 0 {
		aerr: runtime.Allocator_Error
		key, aerr = wstring_to_utf8(&wchValue[0], int(cchValue), allocator = allocator)
		err = i32(aerr)
	}
	if cbData > 0 {
		switch type {
		case win32.REG_SZ:
			aerr: runtime.Allocator_Error
			value, aerr = wstring_to_utf8(([^]u16)(&data[0]), int(cbData), allocator = allocator)
			err = i32(aerr)
		case win32.REG_EXPAND_SZ:
			aerr: runtime.Allocator_Error
			value, aerr = wstring_to_utf8(([^]u16)(&data[0]), int(cbData), allocator = allocator)
			err = i32(aerr)
		case win32.REG_DWORD:
			assert(cbData == size_of(win32.DWORD))
			value = fmt.tprintf("DWORD: %#X", data[0])
		case:
			fmt.printfln("cbData=%d type=%d err=%d", cbData, type, err)
		}
	}
	return
}

check_virtual_terminal_level :: proc() {

	sub_key :: "Console"
	key_name :: "VirtualTerminalLevel"

	fmt.print("Terminal Colors:")
	for tc in has_terminal_colors {fmt.printf(" %s", tc)}
	fmt.println()

	virtual_terminal_level: string
	{
		hKey, err := reg_open_key(win32.HKEY_CURRENT_USER, sub_key, 0, win32.KEY_READ)
		if err != 0 {return}
		defer win32.RegCloseKey(hKey)

		rq: reg_query
		err = reg_query_info_key(hKey, &rq)
		if err != 0 {return}

		// Enumerate the key values.
		if rq.cValues > 0 {
			for i in 0 ..< rq.cValues {
				key, value: string
				key, value, err = reg_enum_value(hKey, i)
				if err == 0 {
					if key == key_name {
						virtual_terminal_level = value
						break
					}
				}
			}
		}
	}
	if virtual_terminal_level == "DWORD: 0x1" {
		fmt.println("Found HKEY_CURRENT_USER\\" + sub_key + "\\" + key_name + "=dword:00000001 " + CHECK_OK)
	} else {
		// fmt.println("Adding HKEY_CURRENT_USER\\" + sub_key + "\\" + key_name + "=dword:00000001")
		fmt.println(key_name + ":", virtual_terminal_level)

		hKey, err := reg_open_key(win32.HKEY_CURRENT_USER, sub_key, 0, win32.KEY_WRITE)
		if err != 0 {
			fmt.eprint("reg_open_key:", err)
			return
		}
		defer win32.RegCloseKey(hKey)
		value: win32.DWORD = 1
		status := win32.RegSetValueExW(hKey, L(key_name), 0, win32.REG_DWORD, (^win32.BYTE)(&value), size_of(win32.DWORD))
		if win32.FAILED(status) {
			fmt.eprint("RegSetValueExW:", status)
		} else {
			fmt.println("Added HKEY_CURRENT_USER\\" + sub_key + "\\" + key_name + "=dword:00000001 " + CHECK_OK)
		}
	}
}

check_environment_variables :: proc() {

	odin_root := strings.trim_right(ODIN_ROOT, _Path_Separator_Str)
	//fmt.println("odin_root:", odin_root)

	found_odin_root := ""
	found_path := ""
	{
		hKey, err := reg_open_key(win32.HKEY_CURRENT_USER, "Environment", 0, win32.KEY_READ)
		if err != 0 {
			fmt.eprint("reg_open_key:", err)
			return
		}
		defer win32.RegCloseKey(hKey)

		rq: reg_query
		err = reg_query_info_key(hKey, &rq)
		if err != 0 {
			fmt.eprint("reg_query_info_key:", hKey, err)
			return
		}

		if rq.cValues > 0 {
			for i in 0 ..< rq.cValues {
				key, value: string
				key, value, err = reg_enum_value(hKey, i)
				if err == 0 {
					switch key {
					case "ODIN_ROOT":
						found_odin_root = value
					case "Path":
						found_path = value
					}
					//fmt.println("Value:", i, key, value)
				}
			}
		}
	}
	fmt.printfln("Found environment variable ODIN_ROOT: %s " + CHECK_OK, found_odin_root)
	if odin_root != found_odin_root {

		hKey, err := reg_open_key(win32.HKEY_CURRENT_USER, "Environment", 0, win32.KEY_WRITE)
		if err != 0 {
			fmt.eprint("reg_open_key:", err)
			return
		}
		defer win32.RegCloseKey(hKey)
		v := utf8_to_wstring(odin_root)
		status := win32.RegSetValueExW(hKey, L("ODIN_ROOT"), 0, win32.REG_SZ, (^win32.BYTE)(v), u32(len(odin_root) * size_of(win32.WCHAR)))
		if win32.FAILED(status) {
			fmt.eprintln("RegSetValueExW:", status)
		} else {
			fmt.printfln("Added HKEY_CURRENT_USER\\Environment\\ODIN_ROOT=%s " + CHECK_OK, v)
		}
	}

	if found_path != "" {
		odin_root_path :: "%ODIN_ROOT%"
		//fmt.println("Path:", found_path)
		parts := strings.split(found_path, _Path_List_Separator_Str)
		found := false
		for p in parts {
			if p == odin_root_path {
				found = true
			}
		}
		if !found {
			fmt.eprintln(odin_root_path + " is not added to the PATH")
		} else {
			fmt.println("Found " + odin_root_path + " in the PATH " + CHECK_OK)
		}
	}

	if .environment_variables in options {
		fmt.println("[Environment Variables]")
		envVarStrings: []wstring = {
			L("OS                  : %OS%"),
			//L("PATH                : %PATH%"),
			L("HOMEPATH            : %HOMEPATH%"),
			L("TEMP                : %TEMP%"),
			L("ODIN_ROOT           : %ODIN_ROOT%"),
		}
		INFO_BUFFER_SIZE :: 32767
		infoBuf: [INFO_BUFFER_SIZE]win32.WCHAR

		for evs in envVarStrings {
			bufCharCount := win32.ExpandEnvironmentStringsW(evs, &infoBuf[0], INFO_BUFFER_SIZE)
			if (bufCharCount > INFO_BUFFER_SIZE) {
				fmt.printfln("  (Buffer too small to expand: \"%s\")", evs)
			} else if bufCharCount == 0 {
				fmt.eprintln("  ExpandEnvironmentStrings")
			} else {
				val, err := wstring_to_utf8(&infoBuf[0], int(bufCharCount))
				if err == nil {
					fmt.printfln("  %s", val)
				}
			}
		}
	}
}

check_acp :: proc() {
	acp := win32.GetACP()
	if acp == wanted_code_page {
		fmt.printfln("Current Active Codepage %v 😃", acp)
		return
	}

	fmt.printfln("Current Active Codepage %v is not %v to make life easier you can enable", acp, wanted_code_page)
	fmt.printfln("Beta: Use Unicode UTF-8 for worldwide language support")
	fmt.printfln("https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page")
	fmt.printfln(
		strings.join({"\tWin+R -> intl.cpl", "\tAdministrative tab", "\tClick the Change system locale button.", "\tEnable Beta: Use Unicode UTF-8 for worldwide language support", "\tReboot"}, "\n"),
	)

	ACP, OEMCP, MACCP: string

	// note: the app needs to be elevated to write to HKEY_LOCAL_MACHINE, otherwise ERROR_ACCESS_DENIED is returned
	hKey, err := reg_open_key(win32.HKEY_LOCAL_MACHINE, "SYSTEM\\CurrentControlSet\\Control\\Nls\\CodePage", 0, win32.KEY_READ)
	if err != 0 {return}
	defer win32.RegCloseKey(hKey)

	rq: reg_query
	err = reg_query_info_key(hKey, &rq)
	if err != 0 {return}

	if rq.cValues > 0 {
		for i in 0 ..< rq.cValues {
			key, value: string
			key, value, err = reg_enum_value(hKey, i)
			if err == 0 {
				//fmt.printfln("(%d) %s= '%s'", i + 1, key, value)
				switch key {
				case "ACP":
					ACP = value
				case "OEMCP":
					OEMCP = value
				case "MACCP":
					MACCP = value
				}
			}
		}
	}

	fmt.println("Found:", ACP, OEMCP, MACCP)
}

// HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths

@(private = "package")
setup_windows :: proc() -> int {
	changed := false

	add_args_to_commands()

	if options != {} {
		fmt.print("Options:")
		for cmd in options {fmt.printf(" %s", cmd)}
		fmt.println()
	}

	check_virtual_terminal_level()
	check_environment_variables()
	check_acp()

	if .sys_info in options {
		print_key_value("Is User Interactive", is_user_interactive())
	}

	if .module_info in options {
		module := win32.GetModuleHandleW(nil)
		print_key_value("Module Filename", get_module_filename(module))
	}

	odin_path := filepath.join({ODIN_ROOT, "odin.exe"}, allocator = context.temp_allocator)
	if .version_info in options {
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
		print_language("Language", langid)

		if .language in options {
			show_string_file_info(info, codepage, langid)
			show_code_pages()
			show_system_defaults()
		}
		if .sys_info in options {
			show_system_info()
		}
	}
	show_module(odin_path)

	//changed = true

	//HICON hicon = LoadImage(NULL, "filename.ico", IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_LOADFROMFILE);

	/*{
		hTestKey: win32.HKEY = nil
		err := win32.RegOpenKeyExW(win32.HKEY_CURRENT_USER, L("Console"), 0, win32.KEY_READ, &hTestKey)
		if err == LSTATUS(win32.ERROR_SUCCESS) {
			defer win32.RegCloseKey(hTestKey)
			query_key(hTestKey)
		}
	}*/
	/*{
		hTestKey : win32.HKEY = nil
		err := win32.RegOpenKeyExW(win32.HKEY_CURRENT_USER, L("SOFTWARE\\Microsoft"), 0, win32.KEY_READ, &hTestKey)
		if err == LSTATUS(win32.ERROR_SUCCESS) {
			defer win32.RegCloseKey(hTestKey);
			query_key(hTestKey);
		}
	}*/

	if changed {
		fmt.println("Notify windows to reload icons...")
		win32.SHChangeNotify(win32.SHCNE_ASSOCCHANGED, win32.SHCNF_IDLIST, nil, nil)
	}

	return 0
}

@(init)
init_console :: proc() {
	enable_virtual_terminal_processing :: proc(which: win32.DWORD) -> bool {
		hnd := win32.GetStdHandle(which)
		mode: win32.DWORD = 0
		if win32.GetConsoleMode(hnd, &mode) {
			if win32.SetConsoleMode(hnd, mode | win32.ENABLE_VIRTUAL_TERMINAL_PROCESSING) {
				return true
			}
		}
		return false
	}
	has_terminal_colors = {}
	if enable_virtual_terminal_processing(win32.STD_OUTPUT_HANDLE) {
		has_terminal_colors |= {.STD_OUTPUT}
	}
	if enable_virtual_terminal_processing(win32.STD_ERROR_HANDLE) {
		has_terminal_colors |= {.STD_ERROR}
	}

	cpi, cpo := win32.GetConsoleCP(), win32.GetConsoleOutputCP()
	if cpi != wanted_code_page {
		fmt.printfln("SetConsoleCP(%d)", wanted_code_page)
		win32.SetConsoleCP(wanted_code_page)
	}
	if cpo != wanted_code_page {
		fmt.printfln("SetConsoleOutputCP(%d)", wanted_code_page)
		win32.SetConsoleOutputCP(wanted_code_page)
	}
}
