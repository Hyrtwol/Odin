#+build windows
package test_core_sys_windows // generated by win32gen

import "core:testing"
import win32 "core:sys/windows"

@(test)
verify_win32_type_sizes :: proc(t: ^testing.T) {
	// minwindef.h
	expect_size(t, win32.ULONG, 4)
	expect_size(t, win32.PULONG, 8)
	expect_size(t, win32.USHORT, 2)
	expect_size(t, win32.PUSHORT, 8)
	expect_size(t, win32.UCHAR, 1)
	expect_size(t, win32.DWORD, 4)
	expect_size(t, win32.BOOL, 4)
	expect_size(t, win32.BYTE, 1)
	expect_size(t, win32.WORD, 2)
	expect_size(t, win32.PBOOL, 8)
	expect_size(t, win32.LPBOOL, 8)
	expect_size(t, win32.PBYTE, 8)
	expect_size(t, win32.LPBYTE, 8)
	expect_size(t, win32.PINT, 8)
	expect_size(t, win32.LPINT, 8)
	expect_size(t, win32.LPWORD, 8)
	expect_size(t, win32.PDWORD, 8)
	expect_size(t, win32.LPDWORD, 8)
	expect_size(t, win32.LPVOID, 8)
	expect_size(t, win32.LPCVOID, 8)
	expect_size(t, win32.INT, 4)
	expect_size(t, win32.UINT, 4)
	expect_size(t, win32.PUINT, 8)
	expect_size(t, win32.UINT_PTR, 8)
	expect_size(t, win32.LONG_PTR, 8)
	expect_size(t, win32.WPARAM, 8)
	expect_size(t, win32.LPARAM, 8)
	expect_size(t, win32.LRESULT, 8)
	expect_size(t, win32.LPHANDLE, 8)
	expect_size(t, win32.HGLOBAL, 8)
	expect_size(t, win32.ATOM, 2)
	expect_size(t, win32.HKEY, 8)
	expect_size(t, win32.PHKEY, 8)
	expect_size(t, win32.HINSTANCE, 8)
	expect_size(t, win32.HMODULE, 8)
	expect_size(t, win32.HRGN, 8)
	expect_size(t, win32.HRSRC, 8)
	// windef.h
	expect_size(t, win32.HWND, 8)
	expect_size(t, win32.HHOOK, 8)
	expect_size(t, win32.HGDIOBJ, 8)
	expect_size(t, win32.HBITMAP, 8)
	expect_size(t, win32.HPALETTE, 8)
	expect_size(t, win32.HBRUSH, 8)
	expect_size(t, win32.HPEN, 8)
	expect_size(t, win32.HFONT, 8)
	expect_size(t, win32.HICON, 8)
	expect_size(t, win32.HMENU, 8)
	expect_size(t, win32.HCURSOR, 8)
	expect_size(t, win32.COLORREF, 4)
	expect_size(t, win32.RECT, 16)
	expect_size(t, win32.POINT, 8)
	expect_size(t, win32.SIZE, 8)
	// wtypes.h
	expect_size(t, win32.DECIMAL, 16)
	// fileapi.h
	expect_size(t, win32.WIN32_FILE_ATTRIBUTE_DATA, 36)
	// libloaderapi.h
	expect_size(t, win32.ENUMRESNAMEPROCW, 8)
	expect_size(t, win32.ENUMRESTYPEPROCW, 8)
	// minwinbase.h
	expect_size(t, win32.SYSTEMTIME, 16)
	expect_size(t, win32.WIN32_FIND_DATAW, 592)
	expect_size(t, win32.CRITICAL_SECTION, 40)
	expect_size(t, win32.REASON_CONTEXT, 32)
	// guiddef.h
	expect_size(t, win32.GUID, 16)
	expect_size(t, win32.IID, 16)
	expect_size(t, win32.CLSID, 16)
	// combaseapi.h
	expect_size(t, win32.SCODE, 4)
	// commdlg.h
	expect_size(t, win32.OPENFILENAMEW, 152)
	// wtypesbase.h
	expect_size(t, win32.OLECHAR, 2)
}

@(test)
verify_win32_enums :: proc(t: ^testing.T) {
	// objbase.h
	// enum COINIT
	expect_value(t, win32.COINIT.MULTITHREADED, 0x00000000)
	expect_value(t, win32.COINIT.APARTMENTTHREADED, 0x00000002)
	expect_value(t, win32.COINIT.DISABLE_OLE1DDE, 0x00000004)
	expect_value(t, win32.COINIT.SPEED_OVER_MEMORY, 0x00000008)
}

@(test)
verify_macros :: proc(t: ^testing.T) {
	// minwindef.h
	expect_value(t, win32.MAKEWORD(1, 2), 0x00000201)
	expect_value(t, win32.MAKEWORD(0x1111, 0x2222), 0x00002211)
	expect_value(t, win32.MAKELONG(1, 2), 0x00020001)
	expect_value(t, win32.MAKELONG(0x1111, 0x2222), 0x22221111)
	expect_value(t, win32.LOWORD(0x12345678), 0x00005678)
	expect_value(t, win32.HIWORD(0x12345678), 0x00001234)
	expect_value(t, u32(win32.LOBYTE(0x1234)), 0x00000034)
	expect_value(t, u32(win32.HIBYTE(0x1234)), 0x00000012)
	// winuser.h
	expect_value(t, win32.MAKEWPARAM(1, 2), 0x00020001)
	expect_value(t, win32.MAKEWPARAM(0x1111, 0x2222), 0x22221111)
	expect_value(t, win32.MAKELPARAM(1, 2), 0x00020001)
	expect_value(t, win32.MAKELPARAM(0x1111, 0x2222), 0x22221111)
	expect_value(t, win32.MAKELRESULT(1, 2), 0x00020001)
	expect_value(t, win32.MAKELRESULT(0x1111, 0x2222), 0x22221111)
	// winnt.h
	expect_value(t, win32.MAKELCID(1, 2), 0x00020001)
	expect_value(t, win32.MAKELCID(0x1111, 0x2222), 0x22221111)
	expect_value(t, win32.MAKELANGID(1, 2), 0x00000801)
	expect_value(t, win32.MAKELANGID(0x111, 0x222), 0x00088911)
	expect_value(t, win32.LANGIDFROMLCID(0x12345678), 0x00005678)
}

@(test)
verify_winnt :: proc(t: ^testing.T) {
	// winnt.h
	expect_size(t, win32.CHAR, 1)
	expect_size(t, win32.SHORT, 2)
	expect_size(t, win32.LONG, 4)
	expect_size(t, win32.WCHAR, 2)
	expect_size(t, win32.ULONGLONG, 8)
	expect_size(t, win32.LARGE_INTEGER, 8)
	expect_size(t, win32.PLARGE_INTEGER, 8)
	expect_size(t, win32.ULARGE_INTEGER, 8)
	expect_size(t, win32.PULARGE_INTEGER, 8)
	expect_size(t, win32.BOOLEAN, 1)
	expect_size(t, win32.HANDLE, 8)
	expect_size(t, win32.PHANDLE, 8)
	expect_size(t, win32.HRESULT, 4)
	expect_size(t, win32.LCID, 4)
	expect_size(t, win32.LANGID, 2)
	expect_size(t, win32.LUID, 8)
	expect_size(t, win32.SECURITY_INFORMATION, 4)
	expect_size(t, win32.ACCESS_MASK, 4)
	expect_size(t, win32.REGSAM, 4)
	expect_value(t, win32.LANG_NEUTRAL, 0x00000000)
	expect_value(t, win32.LANG_INVARIANT, 0x0000007F)
	expect_value(t, win32.SUBLANG_NEUTRAL, 0x00000000)
	expect_value(t, win32.SUBLANG_DEFAULT, 0x00000001)
}

@(test)
verify_winuser :: proc(t: ^testing.T) {
	// winuser.h
	expect_size(t, win32.USEROBJECTFLAGS, 12)
	expect_size(t, win32.MSG, 48)
	expect_size(t, win32.WINDOWPOS, 40)
	expect_size(t, win32.ACCEL, 6)
	expect_size(t, win32.MENUITEMINFOW, 80)
	expect_size(t, win32.PAINTSTRUCT, 72)
	expect_size(t, win32.CREATESTRUCTW, 80)
	expect_size(t, win32.WINDOWPLACEMENT, 44)
	expect_size(t, win32.MOUSEINPUT, 32)
	expect_size(t, win32.KEYBDINPUT, 24)
	expect_size(t, win32.HARDWAREINPUT, 8)
	expect_size(t, win32.INPUT, 40)
	expect_size(t, win32.ICONINFOEXW, 1080)
	expect_size(t, win32.CURSORINFO, 24)
	expect_size(t, win32.WINDOWINFO, 60)
	expect_size(t, win32.RAWINPUTHEADER, 24)
	expect_size(t, win32.RAWMOUSE, 24)
	expect_size(t, win32.RAWKEYBOARD, 16)
	expect_size(t, win32.RAWINPUT, 48)
	expect_size(t, win32.RAWINPUTDEVICE, 16)
	expect_size(t, win32.RAWINPUTDEVICELIST, 16)
	expect_size(t, win32.HRAWINPUT, 8)
	expect_size(t, win32.RID_DEVICE_INFO_HID, 16)
	expect_size(t, win32.RID_DEVICE_INFO_KEYBOARD, 24)
	expect_size(t, win32.RID_DEVICE_INFO_MOUSE, 16)
	expect_size(t, win32.RID_DEVICE_INFO, 32)
	expect_size(t, win32.DRAWTEXTPARAMS, 20)
	expect_size(t, win32.BSMINFO, 32)
	expect_value(t, win32.BROADCAST_QUERY_DENY, 0x424D5144)
	expect_value_64(t, u64(win32.HWND_BROADCAST), 0x0000FFFF)
	expect_value_64(t, u64(win32.HWND_MESSAGE), 0xFFFFFFFFFFFFFFFD)
	expect_value_64(t, uintptr(win32.MAKEINTRESOURCEW(1)), 0x00000001)
	expect_value_64(t, uintptr(win32.MAKEINTRESOURCEW(0x12345678)), 0x00005678)
	expect_value_64(t, uintptr(win32.RT_CURSOR), 0x00000001)
	expect_value_64(t, uintptr(win32.RT_BITMAP), 0x00000002)
	expect_value_64(t, uintptr(win32.RT_ICON), 0x00000003)
	expect_value_64(t, uintptr(win32.RT_MENU), 0x00000004)
	expect_value_64(t, uintptr(win32.RT_DIALOG), 0x00000005)
	expect_value_64(t, uintptr(win32.RT_STRING), 0x00000006)
	expect_value_64(t, uintptr(win32.RT_FONTDIR), 0x00000007)
	expect_value_64(t, uintptr(win32.RT_FONT), 0x00000008)
	expect_value_64(t, uintptr(win32.RT_ACCELERATOR), 0x00000009)
	expect_value_64(t, uintptr(win32.RT_RCDATA), 0x0000000A)
	expect_value_64(t, uintptr(win32.RT_MESSAGETABLE), 0x0000000B)
	expect_value_64(t, uintptr(win32.RT_GROUP_CURSOR), 0x0000000C)
	expect_value_64(t, uintptr(win32.RT_GROUP_ICON), 0x0000000E)
	expect_value_64(t, uintptr(win32.RT_VERSION), 0x00000010)
	expect_value_64(t, uintptr(win32.RT_DLGINCLUDE), 0x00000011)
	expect_value_64(t, uintptr(win32.RT_PLUGPLAY), 0x00000013)
	expect_value_64(t, uintptr(win32.RT_VXD), 0x00000014)
	expect_value_64(t, uintptr(win32.RT_ANICURSOR), 0x00000015)
	expect_value_64(t, uintptr(win32.RT_ANIICON), 0x00000016)
	expect_value_64(t, uintptr(win32.RT_MANIFEST), 0x00000018)
	expect_value_64(t, uintptr(win32.CREATEPROCESS_MANIFEST_RESOURCE_ID), 0x00000001)
	expect_value_64(t, uintptr(win32.ISOLATIONAWARE_MANIFEST_RESOURCE_ID), 0x00000002)
	expect_value_64(t, uintptr(win32.ISOLATIONAWARE_NOSTATICIMPORT_MANIFEST_RESOURCE_ID), 0x00000003)
	expect_value_64(t, uintptr(win32.ISOLATIONPOLICY_MANIFEST_RESOURCE_ID), 0x00000004)
	expect_value_64(t, uintptr(win32.ISOLATIONPOLICY_BROWSER_MANIFEST_RESOURCE_ID), 0x00000005)
	expect_value_64(t, uintptr(win32.MINIMUM_RESERVED_MANIFEST_RESOURCE_ID), 0x00000001)
	expect_value_64(t, uintptr(win32.MAXIMUM_RESERVED_MANIFEST_RESOURCE_ID), 0x00000010)
	expect_value(t, win32.SM_CXICON, 0x0000000B)
	expect_value(t, win32.SM_CYICON, 0x0000000C)
	expect_value(t, win32.LR_DEFAULTCOLOR, 0x00000000)
	expect_value(t, win32.LR_MONOCHROME, 0x00000001)
	expect_value(t, win32.LR_COLOR, 0x00000002)
	expect_value(t, win32.LR_COPYRETURNORG, 0x00000004)
	expect_value(t, win32.LR_COPYDELETEORG, 0x00000008)
	expect_value(t, win32.LR_LOADFROMFILE, 0x00000010)
	expect_value(t, win32.LR_LOADTRANSPARENT, 0x00000020)
	expect_value(t, win32.LR_DEFAULTSIZE, 0x00000040)
	expect_value(t, win32.LR_VGACOLOR, 0x00000080)
	expect_value(t, win32.LR_LOADMAP3DCOLORS, 0x00001000)
	expect_value(t, win32.LR_CREATEDIBSECTION, 0x00002000)
	expect_value(t, win32.LR_COPYFROMRESOURCE, 0x00004000)
	expect_value(t, win32.LR_SHARED, 0x00008000)
	expect_value(t, win32.NIM_ADD, 0x00000000)
	expect_value(t, win32.NIM_MODIFY, 0x00000001)
	expect_value(t, win32.NIM_DELETE, 0x00000002)
	expect_value(t, win32.NIM_SETFOCUS, 0x00000003)
	expect_value(t, win32.NIM_SETVERSION, 0x00000004)
	expect_value(t, win32.NIF_MESSAGE, 0x00000001)
	expect_value(t, win32.NIF_ICON, 0x00000002)
	expect_value(t, win32.NIF_TIP, 0x00000004)
	expect_value(t, win32.NIF_STATE, 0x00000008)
	expect_value(t, win32.NIF_INFO, 0x00000010)
	expect_value(t, win32.NIF_GUID, 0x00000020)
	expect_value(t, win32.NIF_REALTIME, 0x00000040)
	expect_value(t, win32.NIF_SHOWTIP, 0x00000080)
	expect_value(t, win32.MF_INSERT, 0x00000000)
	expect_value(t, win32.MF_CHANGE, 0x00000080)
	expect_value(t, win32.MF_APPEND, 0x00000100)
	expect_value(t, win32.MF_DELETE, 0x00000200)
	expect_value(t, win32.MF_REMOVE, 0x00001000)
	expect_value(t, win32.MF_BYCOMMAND, 0x00000000)
	expect_value(t, win32.MF_BYPOSITION, 0x00000400)
	expect_value(t, win32.MF_SEPARATOR, 0x00000800)
	expect_value(t, win32.MF_ENABLED, 0x00000000)
	expect_value(t, win32.MF_GRAYED, 0x00000001)
	expect_value(t, win32.MF_DISABLED, 0x00000002)
	expect_value(t, win32.MF_UNCHECKED, 0x00000000)
	expect_value(t, win32.MF_CHECKED, 0x00000008)
	expect_value(t, win32.MF_USECHECKBITMAPS, 0x00000200)
	expect_value(t, win32.MF_STRING, 0x00000000)
	expect_value(t, win32.MF_BITMAP, 0x00000004)
	expect_value(t, win32.MF_OWNERDRAW, 0x00000100)
	expect_value(t, win32.MF_POPUP, 0x00000010)
	expect_value(t, win32.MF_MENUBARBREAK, 0x00000020)
	expect_value(t, win32.MF_MENUBREAK, 0x00000040)
	expect_value(t, win32.MF_UNHILITE, 0x00000000)
	expect_value(t, win32.MF_HILITE, 0x00000080)
	expect_value(t, win32.MF_DEFAULT, 0x00001000)
	expect_value(t, win32.MF_SYSMENU, 0x00002000)
	expect_value(t, win32.MF_HELP, 0x00004000)
	expect_value(t, win32.MF_RIGHTJUSTIFY, 0x00004000)
	expect_value(t, win32.MF_MOUSESELECT, 0x00008000)
	expect_value(t, win32.MF_END, 0x00000080)
	expect_value(t, win32.MFS_GRAYED, 0x00000003)
	expect_value(t, win32.MFS_DISABLED, 0x00000003)
	expect_value(t, win32.MFS_CHECKED, 0x00000008)
	expect_value(t, win32.MFS_HILITE, 0x00000080)
	expect_value(t, win32.MFS_ENABLED, 0x00000000)
	expect_value(t, win32.MFS_UNCHECKED, 0x00000000)
	expect_value(t, win32.MFS_UNHILITE, 0x00000000)
	expect_value(t, win32.MFS_DEFAULT, 0x00001000)
	expect_value(t, win32.TPM_LEFTBUTTON, 0x00000000)
	expect_value(t, win32.TPM_RIGHTBUTTON, 0x00000002)
	expect_value(t, win32.TPM_LEFTALIGN, 0x00000000)
	expect_value(t, win32.TPM_CENTERALIGN, 0x00000004)
	expect_value(t, win32.TPM_RIGHTALIGN, 0x00000008)
	expect_value(t, win32.TPM_TOPALIGN, 0x00000000)
	expect_value(t, win32.TPM_VCENTERALIGN, 0x00000010)
	expect_value(t, win32.TPM_BOTTOMALIGN, 0x00000020)
	expect_value(t, win32.TPM_HORIZONTAL, 0x00000000)
	expect_value(t, win32.TPM_VERTICAL, 0x00000040)
	expect_value(t, win32.TPM_NONOTIFY, 0x00000080)
	expect_value(t, win32.TPM_RETURNCMD, 0x00000100)
	expect_value(t, win32.TPM_RECURSE, 0x00000001)
	expect_value(t, win32.TPM_HORPOSANIMATION, 0x00000400)
	expect_value(t, win32.TPM_HORNEGANIMATION, 0x00000800)
	expect_value(t, win32.TPM_VERPOSANIMATION, 0x00001000)
	expect_value(t, win32.TPM_VERNEGANIMATION, 0x00002000)
	expect_value(t, win32.TPM_NOANIMATION, 0x00004000)
	expect_value(t, win32.TPM_LAYOUTRTL, 0x00008000)
	expect_value(t, win32.TPM_WORKAREA, 0x00010000)
	expect_value(t, win32.MIIM_STATE, 0x00000001)
	expect_value(t, win32.MIIM_ID, 0x00000002)
	expect_value(t, win32.MIIM_SUBMENU, 0x00000004)
	expect_value(t, win32.MIIM_CHECKMARKS, 0x00000008)
	expect_value(t, win32.MIIM_TYPE, 0x00000010)
	expect_value(t, win32.MIIM_DATA, 0x00000020)
	expect_value(t, win32.MIIM_STRING, 0x00000040)
	expect_value(t, win32.MIIM_BITMAP, 0x00000080)
	expect_value(t, win32.MIIM_FTYPE, 0x00000100)
	expect_value(t, win32.RIDEV_REMOVE, 0x00000001)
	expect_value(t, win32.RIDEV_EXCLUDE, 0x00000010)
	expect_value(t, win32.RIDEV_PAGEONLY, 0x00000020)
	expect_value(t, win32.RIDEV_NOLEGACY, 0x00000030)
	expect_value(t, win32.RIDEV_INPUTSINK, 0x00000100)
	expect_value(t, win32.RIDEV_CAPTUREMOUSE, 0x00000200)
	expect_value(t, win32.RIDEV_NOHOTKEYS, 0x00000200)
	expect_value(t, win32.RIDEV_APPKEYS, 0x00000400)
	expect_value(t, win32.RIDEV_EXINPUTSINK, 0x00001000)
	expect_value(t, win32.RIDEV_DEVNOTIFY, 0x00002000)
	expect_value(t, win32.RID_HEADER, 0x10000005)
	expect_value(t, win32.RID_INPUT, 0x10000003)
	expect_value(t, win32.RIDI_PREPARSEDDATA, 0x20000005)
	expect_value(t, win32.RIDI_DEVICENAME, 0x20000007)
	expect_value(t, win32.RIDI_DEVICEINFO, 0x2000000B)
	expect_value(t, win32.RIM_TYPEMOUSE, 0x00000000)
	expect_value(t, win32.RIM_TYPEKEYBOARD, 0x00000001)
	expect_value(t, win32.RIM_TYPEHID, 0x00000002)
	// enum INPUT_TYPE used by INPUT
	expect_value(t, win32.INPUT_TYPE.MOUSE, 0x00000000)
	expect_value(t, win32.INPUT_TYPE.KEYBOARD, 0x00000001)
	expect_value(t, win32.INPUT_TYPE.HARDWARE, 0x00000002)
	// enum RAWINPUT_CODE
	expect_value(t, win32.RAWINPUT_CODE.RIM_INPUT, 0x00000000)
	expect_value(t, win32.RAWINPUT_CODE.RIM_INPUTSINK, 0x00000001)
	// enum DrawTextFormat
	expect_value(t, win32.DrawTextFormat.DT_TOP, 0x00000000)
	expect_value(t, win32.DrawTextFormat.DT_LEFT, 0x00000000)
	expect_value(t, win32.DrawTextFormat.DT_CENTER, 0x00000001)
	expect_value(t, win32.DrawTextFormat.DT_RIGHT, 0x00000002)
	expect_value(t, win32.DrawTextFormat.DT_VCENTER, 0x00000004)
	expect_value(t, win32.DrawTextFormat.DT_BOTTOM, 0x00000008)
	expect_value(t, win32.DrawTextFormat.DT_WORDBREAK, 0x00000010)
	expect_value(t, win32.DrawTextFormat.DT_SINGLELINE, 0x00000020)
	expect_value(t, win32.DrawTextFormat.DT_EXPANDTABS, 0x00000040)
	expect_value(t, win32.DrawTextFormat.DT_TABSTOP, 0x00000080)
	expect_value(t, win32.DrawTextFormat.DT_NOCLIP, 0x00000100)
	expect_value(t, win32.DrawTextFormat.DT_EXTERNALLEADING, 0x00000200)
	expect_value(t, win32.DrawTextFormat.DT_CALCRECT, 0x00000400)
	expect_value(t, win32.DrawTextFormat.DT_NOPREFIX, 0x00000800)
	expect_value(t, win32.DrawTextFormat.DT_INTERNAL, 0x00001000)
	expect_value(t, win32.DrawTextFormat.DT_EDITCONTROL, 0x00002000)
	expect_value(t, win32.DrawTextFormat.DT_PATH_ELLIPSIS, 0x00004000)
	expect_value(t, win32.DrawTextFormat.DT_END_ELLIPSIS, 0x00008000)
	expect_value(t, win32.DrawTextFormat.DT_MODIFYSTRING, 0x00010000)
	expect_value(t, win32.DrawTextFormat.DT_RTLREADING, 0x00020000)
	expect_value(t, win32.DrawTextFormat.DT_WORD_ELLIPSIS, 0x00040000)
	expect_value(t, win32.DrawTextFormat.DT_NOFULLWIDTHCHARBREAK, 0x00080000)
	expect_value(t, win32.DrawTextFormat.DT_HIDEPREFIX, 0x00100000)
	expect_value(t, win32.DrawTextFormat.DT_PREFIXONLY, 0x00200000)
	// enum RedrawWindowFlags
	expect_value(t, win32.RedrawWindowFlags.RDW_INVALIDATE, 0x00000001)
	expect_value(t, win32.RedrawWindowFlags.RDW_INTERNALPAINT, 0x00000002)
	expect_value(t, win32.RedrawWindowFlags.RDW_ERASE, 0x00000004)
	expect_value(t, win32.RedrawWindowFlags.RDW_VALIDATE, 0x00000008)
	expect_value(t, win32.RedrawWindowFlags.RDW_NOINTERNALPAINT, 0x00000010)
	expect_value(t, win32.RedrawWindowFlags.RDW_NOERASE, 0x00000020)
	expect_value(t, win32.RedrawWindowFlags.RDW_NOCHILDREN, 0x00000040)
	expect_value(t, win32.RedrawWindowFlags.RDW_ALLCHILDREN, 0x00000080)
	expect_value(t, win32.RedrawWindowFlags.RDW_UPDATENOW, 0x00000100)
	expect_value(t, win32.RedrawWindowFlags.RDW_ERASENOW, 0x00000200)
	expect_value(t, win32.RedrawWindowFlags.RDW_FRAME, 0x00000400)
	expect_value(t, win32.RedrawWindowFlags.RDW_NOFRAME, 0x00000800)
	// enum GetUserObjectInformationFlags
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_FLAGS, 0x00000001)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_NAME, 0x00000002)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_TYPE, 0x00000003)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_USER_SID, 0x00000004)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_HEAPSIZE, 0x00000005)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_IO, 0x00000006)
	expect_value(t, win32.GetUserObjectInformationFlags.UOI_TIMERPROC_EXCEPTION_SUPPRESSION, 0x00000007)
	// enum Monitor_From_Flags
	expect_value(t, win32.Monitor_From_Flags.MONITOR_DEFAULTTONULL, 0x00000000)
	expect_value(t, win32.Monitor_From_Flags.MONITOR_DEFAULTTOPRIMARY, 0x00000001)
	expect_value(t, win32.Monitor_From_Flags.MONITOR_DEFAULTTONEAREST, 0x00000002)
	// bit_set WinEventFlag
	expect_flags(t, win32.WinEventFlags{.SKIPOWNTHREAD}, 0x00000001)
	expect_flags(t, win32.WinEventFlags{.SKIPOWNPROCESS}, 0x00000002)
	expect_flags(t, win32.WinEventFlags{.INCONTEXT}, 0x00000004)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_DLGMODALFRAME}, 0x00000001)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_NOPARENTNOTIFY}, 0x00000004)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_TOPMOST}, 0x00000008)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_ACCEPTFILES}, 0x00000010)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_TRANSPARENT}, 0x00000020)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_MDICHILD}, 0x00000040)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_TOOLWINDOW}, 0x00000080)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_WINDOWEDGE}, 0x00000100)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_CLIENTEDGE}, 0x00000200)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_CONTEXTHELP}, 0x00000400)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_RIGHT}, 0x00001000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_RTLREADING}, 0x00002000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_LEFTSCROLLBAR}, 0x00004000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_CONTROLPARENT}, 0x00010000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_STATICEDGE}, 0x00020000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_APPWINDOW}, 0x00040000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_LAYERED}, 0x00080000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_NOINHERITLAYOUT}, 0x00100000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_NOREDIRECTIONBITMAP}, 0x00200000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_LAYOUTRTL}, 0x00400000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_COMPOSITED}, 0x02000000)
	expect_flags(t, win32.WS_EX_STYLES{.WS_EX_NOACTIVATE}, 0x08000000)
}

@(test)
verify_gdi32 :: proc(t: ^testing.T) {
	// wingdi.h
	expect_size(t, win32.DEVMODEW, 220)
	expect_size(t, win32.RGBQUAD, 4)
	expect_size(t, win32.PIXELFORMATDESCRIPTOR, 40)
	expect_size(t, win32.BITMAPINFOHEADER, 40)
	expect_size(t, win32.BITMAPFILEHEADER, 14)
	expect_size(t, win32.BITMAP, 32)
	expect_size(t, win32.BITMAPV5HEADER, 124)
	expect_size(t, win32.CIEXYZTRIPLE, 36)
	expect_size(t, win32.CIEXYZ, 12)
	expect_size(t, win32.FXPT2DOT30, 4)
	expect_size(t, win32.TEXTMETRICW, 60)
	expect_size(t, win32.POINTFLOAT, 8)
	expect_size(t, win32.GLYPHMETRICSFLOAT, 24)
	expect_size(t, win32.PALETTEENTRY, 4)
	expect_size(t, win32.DESIGNVECTOR, 72)
	expect_value(t, win32.LF_FACESIZE, 0x00000020)
	expect_value(t, win32.LF_FULLFACESIZE, 0x00000040)
	expect_size(t, win32.LOGFONTW, 92)
	expect_size(t, win32.ENUMLOGFONTW, 284)
	expect_size(t, win32.ENUMLOGFONTEXW, 348)
	expect_size(t, win32.ENUMLOGFONTEXDVW, 420)
	expect_size(t, win32.NEWTEXTMETRICW, 76)
	expect_size(t, win32.LAYERPLANEDESCRIPTOR, 32)
	expect_size(t, win32.COLOR16, 2)
	expect_size(t, win32.TRIVERTEX, 16)
	expect_size(t, win32.GRADIENT_TRIANGLE, 12)
	expect_size(t, win32.GRADIENT_RECT, 8)
	expect_size(t, win32.BLENDFUNCTION, 4)
	expect_size(t, win32.DISPLAY_DEVICEW, 840)
	expect_value(t, win32.AC_SRC_OVER, 0x00000000)
	expect_value(t, win32.AC_SRC_ALPHA, 0x00000001)
	expect_value(t, win32.RGB(12, 34, 56), 0x0038220C)
	expect_value(t, win32.PALETTERGB(12, 34, 56), 0x0238220C)
	expect_value(t, win32.PALETTEINDEX(123), 0x0100007B)
	expect_value(t, win32.GRADIENT_FILL_RECT_H, 0x00000000)
	expect_value(t, win32.GRADIENT_FILL_RECT_V, 0x00000001)
	expect_value(t, win32.GRADIENT_FILL_TRIANGLE, 0x00000002)
	expect_value(t, win32.BS_SOLID, 0x00000000)
	expect_value(t, win32.BS_NULL, 0x00000001)
	expect_value(t, win32.BS_HOLLOW, 0x00000001)
	expect_value(t, win32.BS_HATCHED, 0x00000002)
	expect_value(t, win32.BS_PATTERN, 0x00000003)
	expect_value(t, win32.BS_INDEXED, 0x00000004)
	expect_value(t, win32.BS_DIBPATTERN, 0x00000005)
	expect_value(t, win32.BS_DIBPATTERNPT, 0x00000006)
	expect_value(t, win32.BS_PATTERN8X8, 0x00000007)
	expect_value(t, win32.BS_DIBPATTERN8X8, 0x00000008)
	expect_value(t, win32.BS_MONOPATTERN, 0x00000009)
	expect_value(t, win32.HS_HORIZONTAL, 0x00000000)
	expect_value(t, win32.HS_VERTICAL, 0x00000001)
	expect_value(t, win32.HS_FDIAGONAL, 0x00000002)
	expect_value(t, win32.HS_BDIAGONAL, 0x00000003)
	expect_value(t, win32.HS_CROSS, 0x00000004)
	expect_value(t, win32.HS_DIAGCROSS, 0x00000005)
	expect_value(t, win32.HS_API_MAX, 0x0000000C)
	expect_value(t, win32.PS_SOLID, 0x00000000)
	expect_value(t, win32.PS_DASH, 0x00000001)
	expect_value(t, win32.PS_DOT, 0x00000002)
	expect_value(t, win32.PS_DASHDOT, 0x00000003)
	expect_value(t, win32.PS_DASHDOTDOT, 0x00000004)
	expect_value(t, win32.PS_NULL, 0x00000005)
	expect_value(t, win32.PS_INSIDEFRAME, 0x00000006)
	expect_value(t, win32.PS_USERSTYLE, 0x00000007)
	expect_value(t, win32.PS_ALTERNATE, 0x00000008)
	expect_value(t, win32.PS_STYLE_MASK, 0x0000000F)
	expect_value(t, win32.PS_ENDCAP_ROUND, 0x00000000)
	expect_value(t, win32.PS_ENDCAP_SQUARE, 0x00000100)
	expect_value(t, win32.PS_ENDCAP_FLAT, 0x00000200)
	expect_value(t, win32.PS_ENDCAP_MASK, 0x00000F00)
	expect_value(t, win32.PS_JOIN_ROUND, 0x00000000)
	expect_value(t, win32.PS_JOIN_BEVEL, 0x00001000)
	expect_value(t, win32.PS_JOIN_MITER, 0x00002000)
	expect_value(t, win32.PS_COSMETIC, 0x00000000)
	expect_value(t, win32.PS_GEOMETRIC, 0x00010000)
	expect_value(t, win32.PS_TYPE_MASK, 0x000F0000)
	// Binary raster ops
	expect_value(t, win32.R2_BLACK, 0x00000001)
	expect_value(t, win32.R2_NOTMERGEPEN, 0x00000002)
	expect_value(t, win32.R2_MASKNOTPEN, 0x00000003)
	expect_value(t, win32.R2_NOTCOPYPEN, 0x00000004)
	expect_value(t, win32.R2_MASKPENNOT, 0x00000005)
	expect_value(t, win32.R2_NOT, 0x00000006)
	expect_value(t, win32.R2_XORPEN, 0x00000007)
	expect_value(t, win32.R2_NOTMASKPEN, 0x00000008)
	expect_value(t, win32.R2_MASKPEN, 0x00000009)
	expect_value(t, win32.R2_NOTXORPEN, 0x0000000A)
	expect_value(t, win32.R2_NOP, 0x0000000B)
	expect_value(t, win32.R2_MERGENOTPEN, 0x0000000C)
	expect_value(t, win32.R2_COPYPEN, 0x0000000D)
	expect_value(t, win32.R2_MERGEPENNOT, 0x0000000E)
	expect_value(t, win32.R2_MERGEPEN, 0x0000000F)
	expect_value(t, win32.R2_WHITE, 0x00000010)
	// Ternary raster operations
	expect_value(t, win32.SRCCOPY, 0x00CC0020)
	expect_value(t, win32.SRCPAINT, 0x00EE0086)
	expect_value(t, win32.SRCAND, 0x008800C6)
	expect_value(t, win32.SRCINVERT, 0x00660046)
	expect_value(t, win32.SRCERASE, 0x00440328)
	expect_value(t, win32.NOTSRCCOPY, 0x00330008)
	expect_value(t, win32.NOTSRCERASE, 0x001100A6)
	expect_value(t, win32.MERGECOPY, 0x00C000CA)
	expect_value(t, win32.MERGEPAINT, 0x00BB0226)
	expect_value(t, win32.PATCOPY, 0x00F00021)
	expect_value(t, win32.PATPAINT, 0x00FB0A09)
	expect_value(t, win32.PATINVERT, 0x005A0049)
	expect_value(t, win32.DSTINVERT, 0x00550009)
	expect_value(t, win32.BLACKNESS, 0x00000042)
	expect_value(t, win32.WHITENESS, 0x00FF0062)
	expect_value(t, win32.NOMIRRORBITMAP, 0x80000000)
	expect_value(t, win32.CAPTUREBLT, 0x40000000)
	// enum ROP
	expect_value(t, win32.ROP.SRCCOPY, 0x00CC0020)
	expect_value(t, win32.ROP.SRCPAINT, 0x00EE0086)
	expect_value(t, win32.ROP.SRCAND, 0x008800C6)
	expect_value(t, win32.ROP.SRCINVERT, 0x00660046)
	expect_value(t, win32.ROP.SRCERASE, 0x00440328)
	expect_value(t, win32.ROP.NOTSRCCOPY, 0x00330008)
	expect_value(t, win32.ROP.NOTSRCERASE, 0x001100A6)
	expect_value(t, win32.ROP.MERGECOPY, 0x00C000CA)
	expect_value(t, win32.ROP.MERGEPAINT, 0x00BB0226)
	expect_value(t, win32.ROP.PATCOPY, 0x00F00021)
	expect_value(t, win32.ROP.PATPAINT, 0x00FB0A09)
	expect_value(t, win32.ROP.PATINVERT, 0x005A0049)
	expect_value(t, win32.ROP.DSTINVERT, 0x00550009)
	expect_value(t, win32.ROP.BLACKNESS, 0x00000042)
	expect_value(t, win32.ROP.WHITENESS, 0x00FF0062)
	expect_value(t, win32.ROP.NOMIRRORBITMAP, 0x80000000)
	expect_value(t, win32.ROP.CAPTUREBLT, 0x40000000)
	// Region Flags
	expect_value(t, win32.ERROR, 0x00000000)
	expect_value(t, win32.NULLREGION, 0x00000001)
	expect_value(t, win32.SIMPLEREGION, 0x00000002)
	expect_value(t, win32.COMPLEXREGION, 0x00000003)
	expect_value(t, win32.RGN_ERROR, 0x00000000)
	// CombineRgn() Styles
	expect_value(t, win32.RGN_AND, 0x00000001)
	expect_value(t, win32.RGN_OR, 0x00000002)
	expect_value(t, win32.RGN_XOR, 0x00000003)
	expect_value(t, win32.RGN_DIFF, 0x00000004)
	expect_value(t, win32.RGN_COPY, 0x00000005)
	// StretchBlt() Modes
	expect_value(t, win32.BLACKONWHITE, 0x00000001)
	expect_value(t, win32.WHITEONBLACK, 0x00000002)
	expect_value(t, win32.COLORONCOLOR, 0x00000003)
	expect_value(t, win32.HALFTONE, 0x00000004)
	// PolyFill() Modes
	expect_value(t, win32.ALTERNATE, 0x00000001)
	expect_value(t, win32.WINDING, 0x00000002)
	// Layout Orientation Options
	expect_value(t, win32.LAYOUT_RTL, 0x00000001)
	expect_value(t, win32.LAYOUT_BTT, 0x00000002)
	expect_value(t, win32.LAYOUT_VBH, 0x00000004)
	expect_value(t, win32.LAYOUT_ORIENTATIONMASK, 0x00000007)
	// Text Alignment Options
	expect_value(t, win32.TA_NOUPDATECP, 0x00000000)
	expect_value(t, win32.TA_UPDATECP, 0x00000001)
	expect_value(t, win32.TA_LEFT, 0x00000000)
	expect_value(t, win32.TA_RIGHT, 0x00000002)
	expect_value(t, win32.TA_CENTER, 0x00000006)
	expect_value(t, win32.TA_TOP, 0x00000000)
	expect_value(t, win32.TA_BOTTOM, 0x00000008)
	expect_value(t, win32.TA_BASELINE, 0x00000018)
	expect_value(t, win32.TA_RTLREADING, 0x00000100)
	expect_value(t, win32.TA_MASK, 0x0000011F)
	// enum BKMODE
	expect_value(t, win32.BKMODE.TRANSPARENT, 0x00000001)
	expect_value(t, win32.BKMODE.OPAQUE, 0x00000002)
	// enum ArcDirection
	expect_value(t, win32.ArcDirection.AD_COUNTERCLOCKWISE, 0x00000001)
	expect_value(t, win32.ArcDirection.AD_CLOCKWISE, 0x00000002)
	// font constants
	expect_value(t, win32.ANSI_CHARSET, 0x00000000)
	expect_value(t, win32.DEFAULT_CHARSET, 0x00000001)
	expect_value(t, win32.SYMBOL_CHARSET, 0x00000002)
	expect_value(t, win32.SHIFTJIS_CHARSET, 0x00000080)
	expect_value(t, win32.HANGEUL_CHARSET, 0x00000081)
	expect_value(t, win32.HANGUL_CHARSET, 0x00000081)
	expect_value(t, win32.GB2312_CHARSET, 0x00000086)
	expect_value(t, win32.CHINESEBIG5_CHARSET, 0x00000088)
	expect_value(t, win32.OEM_CHARSET, 0x000000FF)
	expect_value(t, win32.JOHAB_CHARSET, 0x00000082)
	expect_value(t, win32.HEBREW_CHARSET, 0x000000B1)
	expect_value(t, win32.ARABIC_CHARSET, 0x000000B2)
	expect_value(t, win32.GREEK_CHARSET, 0x000000A1)
	expect_value(t, win32.TURKISH_CHARSET, 0x000000A2)
	expect_value(t, win32.VIETNAMESE_CHARSET, 0x000000A3)
	expect_value(t, win32.THAI_CHARSET, 0x000000DE)
	expect_value(t, win32.EASTEUROPE_CHARSET, 0x000000EE)
	expect_value(t, win32.RUSSIAN_CHARSET, 0x000000CC)
	expect_value(t, win32.MAC_CHARSET, 0x0000004D)
	expect_value(t, win32.BALTIC_CHARSET, 0x000000BA)
	expect_value(t, win32.FS_LATIN1, 0x00000001)
	expect_value(t, win32.FS_LATIN2, 0x00000002)
	expect_value(t, win32.FS_CYRILLIC, 0x00000004)
	expect_value(t, win32.FS_GREEK, 0x00000008)
	expect_value(t, win32.FS_TURKISH, 0x00000010)
	expect_value(t, win32.FS_HEBREW, 0x00000020)
	expect_value(t, win32.FS_ARABIC, 0x00000040)
	expect_value(t, win32.FS_BALTIC, 0x00000080)
	expect_value(t, win32.FS_VIETNAMESE, 0x00000100)
	expect_value(t, win32.FS_THAI, 0x00010000)
	expect_value(t, win32.FS_JISJAPAN, 0x00020000)
	expect_value(t, win32.FS_CHINESESIMP, 0x00040000)
	expect_value(t, win32.FS_WANSUNG, 0x00080000)
	expect_value(t, win32.FS_CHINESETRAD, 0x00100000)
	expect_value(t, win32.FS_JOHAB, 0x00200000)
	expect_value(t, win32.FS_SYMBOL, 0x80000000)
	expect_value(t, win32.OUT_DEFAULT_PRECIS, 0x00000000)
	expect_value(t, win32.OUT_STRING_PRECIS, 0x00000001)
	expect_value(t, win32.OUT_CHARACTER_PRECIS, 0x00000002)
	expect_value(t, win32.OUT_STROKE_PRECIS, 0x00000003)
	expect_value(t, win32.OUT_TT_PRECIS, 0x00000004)
	expect_value(t, win32.OUT_DEVICE_PRECIS, 0x00000005)
	expect_value(t, win32.OUT_RASTER_PRECIS, 0x00000006)
	expect_value(t, win32.OUT_TT_ONLY_PRECIS, 0x00000007)
	expect_value(t, win32.OUT_OUTLINE_PRECIS, 0x00000008)
	expect_value(t, win32.OUT_SCREEN_OUTLINE_PRECIS, 0x00000009)
	expect_value(t, win32.OUT_PS_ONLY_PRECIS, 0x0000000A)
	expect_value(t, win32.CLIP_DEFAULT_PRECIS, 0x00000000)
	expect_value(t, win32.CLIP_CHARACTER_PRECIS, 0x00000001)
	expect_value(t, win32.CLIP_STROKE_PRECIS, 0x00000002)
	expect_value(t, win32.CLIP_MASK, 0x0000000F)
	expect_value(t, win32.CLIP_LH_ANGLES, 0x00000010)
	expect_value(t, win32.CLIP_TT_ALWAYS, 0x00000020)
	expect_value(t, win32.CLIP_DFA_DISABLE, 0x00000040)
	expect_value(t, win32.CLIP_EMBEDDED, 0x00000080)
	expect_value(t, win32.DEFAULT_QUALITY, 0x00000000)
	expect_value(t, win32.DRAFT_QUALITY, 0x00000001)
	expect_value(t, win32.PROOF_QUALITY, 0x00000002)
	expect_value(t, win32.NONANTIALIASED_QUALITY, 0x00000003)
	expect_value(t, win32.ANTIALIASED_QUALITY, 0x00000004)
	expect_value(t, win32.CLEARTYPE_QUALITY, 0x00000005)
	expect_value(t, win32.CLEARTYPE_NATURAL_QUALITY, 0x00000006)
	expect_value(t, win32.DEFAULT_PITCH, 0x00000000)
	expect_value(t, win32.FIXED_PITCH, 0x00000001)
	expect_value(t, win32.VARIABLE_PITCH, 0x00000002)
	expect_value(t, win32.MONO_FONT, 0x00000008)
	expect_value(t, win32.FF_DONTCARE, 0x00000000)
	expect_value(t, win32.FF_ROMAN, 0x00000010)
	expect_value(t, win32.FF_SWISS, 0x00000020)
	expect_value(t, win32.FF_MODERN, 0x00000030)
	expect_value(t, win32.FF_SCRIPT, 0x00000040)
	expect_value(t, win32.FF_DECORATIVE, 0x00000050)
}

@(test)
verify_winmm :: proc(t: ^testing.T) {
	// timeapi.h
	expect_size(t, win32.TIMECAPS, 8)
	// mmsyscom.h
	expect_size(t, win32.MMVERSION, 4)
	expect_size(t, win32.MMTIME, 12)
	// mmeapi.h
	expect_size(t, win32.WAVEFORMATEX, 20)
	expect_size(t, win32.WAVEHDR, 48)
	expect_size(t, win32.WAVEINCAPSW, 80)
	expect_size(t, win32.WAVEOUTCAPSW, 84)
}

@(test)
verify_advapi32 :: proc(t: ^testing.T) {
	// wincrypt.h
	expect_size(t, win32.HCRYPTPROV, 8)
}

@(test)
verify_winnls :: proc(t: ^testing.T) {
	// winnls.h
	expect_value(t, win32.CP_ACP, 0x00000000)
	expect_value(t, win32.CP_OEMCP, 0x00000001)
	expect_value(t, win32.CP_MACCP, 0x00000002)
	expect_value(t, win32.CP_THREAD_ACP, 0x00000003)
	expect_value(t, win32.CP_SYMBOL, 0x0000002A)
	expect_value(t, win32.CP_UTF7, 0x0000FDE8)
	expect_value(t, win32.CP_UTF8, 0x0000FDE9)
	expect_value(t, win32.MAX_DEFAULTCHAR, 0x00000002)
	expect_value(t, win32.MAX_LEADBYTES, 0x0000000C)
	expect_value(t, win32.LOCALE_NAME_MAX_LENGTH, 0x00000055)
	expect_value(t, win32.LOCALE_NAME_USER_DEFAULT, 0x00000000)
	expect_value_str(t, win32.LOCALE_NAME_INVARIANT, L(""))
	expect_value_str(t, win32.LOCALE_NAME_SYSTEM_DEFAULT, L("!x-sys-default-locale"))
	expect_size(t, win32.LCTYPE, 4)
	expect_size(t, win32.CPINFOEXW, 544)
}

@(test)
verify_winreg :: proc(t: ^testing.T) {
	// winreg.h
	expect_value(t, win32.RRF_RT_REG_NONE, 0x00000001)
	expect_value(t, win32.RRF_RT_REG_SZ, 0x00000002)
	expect_value(t, win32.RRF_RT_REG_EXPAND_SZ, 0x00000004)
	expect_value(t, win32.RRF_RT_REG_BINARY, 0x00000008)
	expect_value(t, win32.RRF_RT_REG_DWORD, 0x00000010)
	expect_value(t, win32.RRF_RT_REG_MULTI_SZ, 0x00000020)
	expect_value(t, win32.RRF_RT_REG_QWORD, 0x00000040)
	expect_value(t, win32.RRF_RT_DWORD, 0x00000018)
	expect_value(t, win32.RRF_RT_QWORD, 0x00000048)
	expect_value(t, win32.RRF_RT_ANY, 0x0000FFFF)
	expect_value(t, win32.RRF_NOEXPAND, 0x10000000)
	expect_value(t, win32.RRF_ZEROONFAILURE, 0x20000000)
	// winnt.h
	expect_value(t, u32(win32.HKEY_CLASSES_ROOT), 0x80000000)
	expect_value(t, u32(win32.HKEY_CURRENT_USER), 0x80000001)
	expect_value(t, u32(win32.HKEY_LOCAL_MACHINE), 0x80000002)
	expect_value(t, u32(win32.HKEY_USERS), 0x80000003)
	expect_value(t, u32(win32.HKEY_PERFORMANCE_DATA), 0x80000004)
	expect_value(t, u32(win32.HKEY_PERFORMANCE_TEXT), 0x80000050)
	expect_value(t, u32(win32.HKEY_PERFORMANCE_NLSTEXT), 0x80000060)
	expect_value(t, u32(win32.HKEY_CURRENT_CONFIG), 0x80000005)
	expect_value(t, u32(win32.HKEY_DYN_DATA), 0x80000006)
	expect_value(t, u32(win32.HKEY_CURRENT_USER_LOCAL_SETTINGS), 0x80000007)
	expect_value(t, win32.DELETE, 0x00010000)
	expect_value(t, win32.READ_CONTROL, 0x00020000)
	expect_value(t, win32.WRITE_DAC, 0x00040000)
	expect_value(t, win32.WRITE_OWNER, 0x00080000)
	expect_value(t, win32.SYNCHRONIZE, 0x00100000)
	expect_value(t, win32.KEY_QUERY_VALUE, 0x00000001)
	expect_value(t, win32.KEY_SET_VALUE, 0x00000002)
	expect_value(t, win32.KEY_CREATE_SUB_KEY, 0x00000004)
	expect_value(t, win32.KEY_ENUMERATE_SUB_KEYS, 0x00000008)
	expect_value(t, win32.KEY_NOTIFY, 0x00000010)
	expect_value(t, win32.KEY_CREATE_LINK, 0x00000020)
	expect_value(t, win32.KEY_WOW64_32KEY, 0x00000200)
	expect_value(t, win32.KEY_WOW64_64KEY, 0x00000100)
	expect_value(t, win32.KEY_WOW64_RES, 0x00000300)
	expect_value(t, win32.KEY_READ, 0x00020019)
	expect_value(t, win32.KEY_WRITE, 0x00020006)
	expect_value(t, win32.KEY_EXECUTE, 0x00020019)
	expect_value(t, win32.KEY_ALL_ACCESS, 0x000F003F)
}

@(test)
verify_verrsrc :: proc(t: ^testing.T) {
	// verrsrc.h
	expect_value(t, win32.VS_VERSION_INFO, 0x00000001)
	expect_value(t, win32.VS_USER_DEFINED, 0x00000064)
	expect_size(t, win32.VS_FIXEDFILEINFO, 52)
	expect_value(t, win32.VS_FFI_SIGNATURE, 0xFEEF04BD)
}

@(test)
verify_error_codes :: proc(t: ^testing.T) {
	// winerror.h
	expect_value(t, win32.ERROR_SUCCESS, 0x00000000)
	expect_value(t, win32.NO_ERROR, 0x00000000)
	expect_value(t, win32.SEC_E_OK, 0x00000000)

	expect_value(t, win32.ERROR_INVALID_FUNCTION, 0x00000001)
	expect_value(t, win32.ERROR_FILE_NOT_FOUND, 0x00000002)
	expect_value(t, win32.ERROR_PATH_NOT_FOUND, 0x00000003)
	expect_value(t, win32.ERROR_ACCESS_DENIED, 0x00000005)
	expect_value(t, win32.ERROR_INVALID_HANDLE, 0x00000006)
	expect_value(t, win32.ERROR_NOT_ENOUGH_MEMORY, 0x00000008)
	expect_value(t, win32.ERROR_INVALID_BLOCK, 0x00000009)
	expect_value(t, win32.ERROR_BAD_ENVIRONMENT, 0x0000000A)
	expect_value(t, win32.ERROR_BAD_FORMAT, 0x0000000B)
	expect_value(t, win32.ERROR_INVALID_ACCESS, 0x0000000C)
	expect_value(t, win32.ERROR_INVALID_DATA, 0x0000000D)
	expect_value(t, win32.ERROR_OUTOFMEMORY, 0x0000000E)
	expect_value(t, win32.ERROR_INVALID_DRIVE, 0x0000000F)
	expect_value(t, win32.ERROR_CURRENT_DIRECTORY, 0x00000010)
	expect_value(t, win32.ERROR_NO_MORE_FILES, 0x00000012)
	expect_value(t, win32.ERROR_SHARING_VIOLATION, 0x00000020)
	expect_value(t, win32.ERROR_LOCK_VIOLATION, 0x00000021)
	expect_value(t, win32.ERROR_HANDLE_EOF, 0x00000026)
	expect_value(t, win32.ERROR_NOT_SUPPORTED, 0x00000032)
	expect_value(t, win32.ERROR_FILE_EXISTS, 0x00000050)
	expect_value(t, win32.ERROR_INVALID_PARAMETER, 0x00000057)
	expect_value(t, win32.ERROR_BROKEN_PIPE, 0x0000006D)
	expect_value(t, win32.ERROR_CALL_NOT_IMPLEMENTED, 0x00000078)
	expect_value(t, win32.ERROR_INSUFFICIENT_BUFFER, 0x0000007A)
	expect_value(t, win32.ERROR_INVALID_NAME, 0x0000007B)
	expect_value(t, win32.ERROR_BAD_ARGUMENTS, 0x000000A0)
	expect_value(t, win32.ERROR_LOCK_FAILED, 0x000000A7)
	expect_value(t, win32.ERROR_ALREADY_EXISTS, 0x000000B7)
	expect_value(t, win32.ERROR_NO_DATA, 0x000000E8)
	expect_value(t, win32.ERROR_ENVVAR_NOT_FOUND, 0x000000CB)
	expect_value(t, win32.ERROR_OPERATION_ABORTED, 0x000003E3)
	expect_value(t, win32.ERROR_IO_PENDING, 0x000003E5)
	expect_value(t, win32.ERROR_NO_UNICODE_TRANSLATION, 0x00000459)
	expect_value(t, win32.ERROR_TIMEOUT, 0x000005B4)
	expect_value(t, win32.ERROR_DATATYPE_MISMATCH, 0x0000065D)
	expect_value(t, win32.ERROR_UNSUPPORTED_TYPE, 0x0000065E)
	expect_value(t, win32.ERROR_NOT_SAME_OBJECT, 0x00000678)
	expect_value(t, win32.ERROR_PIPE_CONNECTED, 0x00000217)
	expect_value(t, win32.ERROR_PIPE_BUSY, 0x000000E7)

	expect_value(t, win32.S_OK, 0x00000000)
	expect_value(t, win32.E_NOTIMPL, 0x80004001)
	expect_value(t, win32.E_NOINTERFACE, 0x80004002)
	expect_value(t, win32.E_POINTER, 0x80004003)
	expect_value(t, win32.E_ABORT, 0x80004004)
	expect_value(t, win32.E_FAIL, 0x80004005)
	expect_value(t, win32.E_UNEXPECTED, 0x8000FFFF)
	expect_value(t, win32.E_ACCESSDENIED, 0x80070005)
	expect_value(t, win32.E_HANDLE, 0x80070006)
	expect_value(t, win32.E_OUTOFMEMORY, 0x8007000E)
	expect_value(t, win32.E_INVALIDARG, 0x80070057)
}

@(test)
verify_error_helpers :: proc(t: ^testing.T) {
	// winerror.h
	expect_value(t, win32.SUCCEEDED(-1), 0x00000000)
	expect_value(t, win32.SUCCEEDED(0), 0x00000001)
	expect_value(t, win32.SUCCEEDED(1), 0x00000001)

	expect_value(t, win32.FAILED(-1), 0x00000001)
	expect_value(t, win32.FAILED(0), 0x00000000)
	expect_value(t, win32.FAILED(1), 0x00000000)

	expect_value(t, win32.IS_ERROR(-1), 0x00000001)
	expect_value(t, win32.IS_ERROR(0), 0x00000000)
	expect_value(t, win32.IS_ERROR(1), 0x00000000)

	expect_value(t, win32.HRESULT_CODE(0xFFFFCCCC), 0x0000CCCC)
	expect_value(t, win32.HRESULT_FACILITY(0xFFFFCCCC), 0x00001FFF)
	expect_value(t, win32.HRESULT_SEVERITY(0x12345678), 0x00000000)
	expect_value(t, win32.HRESULT_SEVERITY(0x87654321), 0x00000001)

	expect_value(t, win32.MAKE_HRESULT(1, 2, 3), 0x80020003)
}
