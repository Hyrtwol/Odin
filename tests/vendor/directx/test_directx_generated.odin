#+build windows
package test_vendor_directx // generated by directxgen

import "core:testing"
import dxgi "vendor:directx/dxgi"

@(test)
verify_dxgi1_4 :: proc(t: ^testing.T) {
	// dxgi1_4.h
	expect_size(t, dxgi.LUID, 8)
	expect_size(t, dxgi.IID, 16)
	expect_size(t, dxgi.UUID, 16)
	expect_size(t, dxgi.GUID, 16)
	expect_size(t, dxgi.HANDLE, 8)
	expect_size(t, dxgi.HRESULT, 4)
	expect_size(t, dxgi.HMONITOR, 8)
	expect_size(t, dxgi.HWND, 8)
	expect_size(t, dxgi.HMODULE, 8)
	expect_size(t, dxgi.HDC, 8)
	expect_size(t, dxgi.BOOL, 4)
	expect_size(t, dxgi.LARGE_INTEGER, 8)
	expect_size(t, dxgi.SIZE_T, 8)
	expect_size(t, dxgi.ULONG, 4)
	expect_size(t, dxgi.LONG, 4)
	expect_size(t, dxgi.RECT, 16)
	expect_size(t, dxgi.POINT, 8)
	expect_size(t, dxgi.SIZE, 8)
	expect_size(t, dxgi.WCHAR, 2)
	expect_size(t, dxgi.DWORD, 4)
	expect_size(t, dxgi.IUnknown, 8)
	expect_size(t, dxgi.LPUNKNOWN, 8)
}

@(test)
verify_error_codes :: proc(t: ^testing.T) {
	// winerror.h
	expect_value(t, dxgi.ERROR_ACCESS_DENIED, 0x887A002B)
	expect_value(t, dxgi.ERROR_ACCESS_LOST, 0x887A0026)
	expect_value(t, dxgi.ERROR_ALREADY_EXISTS, 0x887A0036)
	expect_value(t, dxgi.ERROR_CANNOT_PROTECT_CONTENT, 0x887A002A)
	expect_value(t, dxgi.ERROR_DEVICE_HUNG, 0x887A0006)
	expect_value(t, dxgi.ERROR_DEVICE_REMOVED, 0x887A0005)
	expect_value(t, dxgi.ERROR_DEVICE_RESET, 0x887A0007)
	expect_value(t, dxgi.ERROR_DRIVER_INTERNAL_ERROR, 0x887A0020)
	expect_value(t, dxgi.ERROR_FRAME_STATISTICS_DISJOINT, 0x887A000B)
	expect_value(t, dxgi.ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE, 0x887A000C)
	expect_value(t, dxgi.ERROR_INVALID_CALL, 0x887A0001)
	expect_value(t, dxgi.ERROR_MORE_DATA, 0x887A0003)
	expect_value(t, dxgi.ERROR_NAME_ALREADY_EXISTS, 0x887A002C)
	expect_value(t, dxgi.ERROR_NONEXCLUSIVE, 0x887A0021)
	expect_value(t, dxgi.ERROR_NOT_CURRENTLY_AVAILABLE, 0x887A0022)
	expect_value(t, dxgi.ERROR_NOT_FOUND, 0x887A0002)
	expect_value(t, dxgi.ERROR_REMOTE_CLIENT_DISCONNECTED, 0x887A0023)
	expect_value(t, dxgi.ERROR_REMOTE_OUTOFMEMORY, 0x887A0024)
	expect_value(t, dxgi.ERROR_RESTRICT_TO_OUTPUT_STALE, 0x887A0029)
	expect_value(t, dxgi.ERROR_SDK_COMPONENT_MISSING, 0x887A002D)
	expect_value(t, dxgi.ERROR_SESSION_DISCONNECTED, 0x887A0028)
	expect_value(t, dxgi.ERROR_UNSUPPORTED, 0x887A0004)
	expect_value(t, dxgi.ERROR_WAIT_TIMEOUT, 0x887A0027)
	expect_value(t, dxgi.ERROR_WAS_STILL_DRAWING, 0x887A000A)

	expect_value(t, dxgi.STATUS_OCCLUDED, 0x087A0001)
	expect_value(t, dxgi.STATUS_MODE_CHANGED, 0x087A0007)
	expect_value(t, dxgi.STATUS_MODE_CHANGE_IN_PROGRESS, 0x087A0008)
}
