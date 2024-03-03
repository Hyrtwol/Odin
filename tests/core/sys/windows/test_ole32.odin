//+build windows
package test_core_sys_windows

//import "core:fmt"
import "core:testing"
import win32 "core:sys/windows"

@(test)
string_from_clsid :: proc(t: ^testing.T) {
	p : win32.LPOLESTR
	hr := win32.StringFromCLSID(win32.CLSID_FileOpenDialog, &p)
	defer if p != nil {win32.CoTaskMemFree(p)}

	testing.expectf(t, win32.SUCCEEDED(hr), "%x (should be: %x)", u32(hr), 0)
	testing.expectf(t, p != nil, "%v is nil", p)

	str, err := win32.wstring_to_utf8(p, 40)

	testing.expectf(t, err == .None, "%v (should be: %x)", err, 0)
	exp :: "{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}"
	testing.expectf(t, str == exp, "%v (should be: %v)", err, exp)
}

/*
@(test)
clsid_from_string :: proc(t: ^testing.T) {
	using win32

	fmt.printf("%v\n", CLSID_FileOpenDialog)

	// &GUID{Data1 = 3692845724, Data2 = 59530, Data3 = 19934, Data4 = [165, 161, 96, 248, 42, 32, 174, 247]}

	guid :: cstring("{73E22D93-E6CE-47F3-B5BF-F0664F39C1B0}")
	clsid : CLSID //= nil
	hr := CLSIDFromString(guid, &clsid)
	testing.expectf(t, hr == 0, "%x (should be: %x)", u32(hr), 0)

	exp : LPCLSID = CLSID_FileOpenDialog
	//testing.expectf(t, hr == exp, "%v (should be: %v)", hr, exp)
}
*/


	// hr := CoInitializeEx(nil, .MULTITHREADED);
	// testing.expectf(t, hr == 0, "%x (should be: %v)", u32(hr), 0)
	// assert(SUCCEEDED(hr))
	// defer CoUninitialize()
