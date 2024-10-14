#+build windows
package test_core_sys_windows

import "core:testing"
import win32 "core:sys/windows"

@(test)
make_lresult_from_false :: proc(t: ^testing.T) {
	exp := win32.LRESULT(0)
	result := win32.MAKELRESULT(false)
	testing.expectf(t, exp == result, "MAKELRESULT: %v -> %v (should be: %v)", false, result, exp)
}

@(test)
make_lresult_from_true :: proc(t: ^testing.T) {
	exp := win32.LRESULT(1)
	result := win32.MAKELRESULT(true)
	testing.expectf(t, exp == result, "MAKELRESULT: %v -> %v (should be: %v)", false, result, exp)
}

@(test)
verify_rawinput_code :: proc(t: ^testing.T) {
	expect_value(t, win32.GET_RAWINPUT_CODE_WPARAM(0), win32.RAWINPUT_CODE.RIM_INPUT)
	expect_value(t, win32.GET_RAWINPUT_CODE_WPARAM(1), win32.RAWINPUT_CODE.RIM_INPUTSINK)
	expect_value(t, win32.GET_RAWINPUT_CODE_WPARAM(0x100), win32.RAWINPUT_CODE.RIM_INPUT)
	expect_value(t, win32.GET_RAWINPUT_CODE_WPARAM(0x101), win32.RAWINPUT_CODE.RIM_INPUTSINK)
}
