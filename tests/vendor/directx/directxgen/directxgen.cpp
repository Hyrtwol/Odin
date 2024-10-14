#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <timeapi.h>
#include <mmeapi.h>
#include <windns.h>
#include <commdlg.h>
#include <winver.h>
#include <shobjidl.h>
#include <shellapi.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <wincrypt.h>

#include <windows.h>
#include <wrl.h>
#include <dxgi1_4.h>
#include <d3d12.h>
#include <D3Dcompiler.h>
#include <DirectXMath.h>
#include <DirectXPackedVector.h>
#include <DirectXColors.h>
#include <DirectXCollision.h>
#include <string>
#include <memory>
#include <algorithm>
#include <vector>
#include <array>
#include <unordered_map>
#include <cstdint>
#include <fstream>
#include <sstream>
#include <cassert>

#define sut "dxgi"
#include "..\..\..\..\misc\testgen\odintestgen.h"

static void verify_dxgi1_4(ofstream& out) {
	test_proc_begin();
	test_proc_comment("dxgi1_4.h");

	expect_size(LUID);
	expect_size(IID);
	expect_size(UUID);
	expect_size(GUID);
	expect_size(HANDLE);
	expect_size(HRESULT);
	expect_size(HMONITOR);
	expect_size(HWND);
	expect_size(HMODULE);
	expect_size(HDC);
	expect_size(BOOL);
	expect_size(LARGE_INTEGER);
	expect_size(SIZE_T);
	expect_size(ULONG);
	expect_size(LONG);
	expect_size(RECT);
	expect_size(POINT);
	expect_size(SIZE);
	expect_size(WCHAR);
	expect_size(DWORD);

	// Unknwnbase.h
	expect_size(IUnknown);
	//expect_size(IUnknown_VTable         );
	expect_size(LPUNKNOWN);

	//expect_value(STANDARD_MULTISAMPLE_QUALITY_PATTERN);
	//expect_value(CENTER_MULTISAMPLE_QUALITY_PATTERN);
	//expect_value(FORMAT_DEFINED);

	test_proc_end();
}

static void verify_error_codes(ofstream& out) {
	test_proc_begin();
	test_proc_comment("winerror.h");

	expect_value_trim(DXGI_ERROR_ACCESS_DENIED);
	expect_value_trim(DXGI_ERROR_ACCESS_LOST);
	expect_value_trim(DXGI_ERROR_ALREADY_EXISTS);
	expect_value_trim(DXGI_ERROR_CANNOT_PROTECT_CONTENT);
	expect_value_trim(DXGI_ERROR_DEVICE_HUNG);
	expect_value_trim(DXGI_ERROR_DEVICE_REMOVED);
	expect_value_trim(DXGI_ERROR_DEVICE_RESET);
	expect_value_trim(DXGI_ERROR_DRIVER_INTERNAL_ERROR);
	expect_value_trim(DXGI_ERROR_FRAME_STATISTICS_DISJOINT);
	expect_value_trim(DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE);
	expect_value_trim(DXGI_ERROR_INVALID_CALL);
	expect_value_trim(DXGI_ERROR_MORE_DATA);
	expect_value_trim(DXGI_ERROR_NAME_ALREADY_EXISTS);
	expect_value_trim(DXGI_ERROR_NONEXCLUSIVE);
	expect_value_trim(DXGI_ERROR_NOT_CURRENTLY_AVAILABLE);
	expect_value_trim(DXGI_ERROR_NOT_FOUND);
	expect_value_trim(DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED);
	expect_value_trim(DXGI_ERROR_REMOTE_OUTOFMEMORY);
	expect_value_trim(DXGI_ERROR_RESTRICT_TO_OUTPUT_STALE);
	expect_value_trim(DXGI_ERROR_SDK_COMPONENT_MISSING);
	expect_value_trim(DXGI_ERROR_SESSION_DISCONNECTED);
	expect_value_trim(DXGI_ERROR_UNSUPPORTED);
	expect_value_trim(DXGI_ERROR_WAIT_TIMEOUT);
	expect_value_trim(DXGI_ERROR_WAS_STILL_DRAWING);

	out << endl;

	expect_value_trim(DXGI_STATUS_OCCLUDED);
	expect_value_trim(DXGI_STATUS_MODE_CHANGED);
	expect_value_trim(DXGI_STATUS_MODE_CHANGE_IN_PROGRESS);
	test_proc_end();
}

static void test_vendor_directx(ofstream& out) {
	out << "#+build windows" << endl
		<< "package " << __func__
		<< " // generated by " << path(__FILE__).filename().replace_extension("").string() << endl
		<< endl
		<< "import \"core:testing\"" << endl
		<< "import dxgi \"vendor:directx/dxgi\"" << endl;

	verify_dxgi1_4(out);

	verify_error_codes(out);
}

int main(int argc, char* argv[]) {
	if (argc < 2) { cout << "Usage: " << path(argv[0]).filename().string() << " <odin-output-file>" << endl; return -1; }
	auto filepath = path(argv[1]);
	cout << "Writing " << filepath.string() << endl;
	ofstream out(filepath);
	test_vendor_directx(out);
	out.close();
}
