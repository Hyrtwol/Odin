//+build windows
package test_core_sys_windows

import "core:testing"
import "core:fmt"
import "core:os"
import "core:intrinsics"
import win32 "core:sys/windows"

L :: intrinsics.constant_utf16_cstring

TEST_count := 0
TEST_fail  := 0

t := &testing.T{}

when ODIN_TEST {
    expect  :: testing.expect
    expectf :: testing.expectf
    log     :: testing.log
    fmt     :: fmt
} else {
    expect  :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) {
        TEST_count += 1
        if !condition {
            TEST_fail += 1
            fmt.printf("[%v] %v\n", loc, message)
            return
        }
    }
	expectf :: proc(t: ^testing.T, ok: bool, format: string, args: ..any, loc := #caller_location) {
		TEST_count += 1
        if !ok {
            TEST_fail += 1
            fmt.printf(format, ..args)
            return
        }
	}
    log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
        fmt.printf("[%v] ", loc)
        fmt.printf("log: %v\n", v)
    }
}

@(private)
expect_size :: proc(t: ^testing.T, $act: typeid, exp: int, loc := #caller_location) {
	expectf(t, size_of(act) == exp,
		"size_of(%v) should be %d was %d", typeid_of(act), exp, size_of(act), loc=loc)
}

@(private)
expect_value :: proc(t: ^testing.T, #any_int act: u32, #any_int exp: u32, loc := #caller_location) {
	expectf(t, act == exp, "0x%8X (should be: 0x%8X)", act, exp, loc=loc)
}

@(private)
expect_value_64 :: proc(t: ^testing.T, #any_int act: u64, #any_int exp: u64, loc := #caller_location) {
	expectf(t, act == exp, "0x%8X (should be: 0x%8X)", act, exp, loc=loc)
}

@(private)
expect_value_str :: proc(t: ^testing.T, wact, wexp: win32.wstring, loc := #caller_location) {
	act, aerr := win32.wstring_to_utf8(wact, 16)
	exp, eerr := win32.wstring_to_utf8(wexp, 16)
	expectf(t, aerr == .None, "0x%8X (should be: 0x%8X)", aerr, 0, loc=loc)
	expectf(t, eerr == .None, "0x%8X (should be: 0x%8X)", eerr, 0, loc=loc)
	expectf(t, act == exp, "0x%8X (should be: 0x%8X)", act, exp, loc=loc)
}

main :: proc() {
	verify_win32_type_sizes(t)
	verify_winnt(t)
	verify_winuser(t)
	verify_gdi32(t)
	verify_winmm(t)
	verify_winnls(t)
	verify_error_codes(t)
	verify_error_helpers(t)

	fmt.printf("%v/%v tests successful.\n", TEST_count - TEST_fail, TEST_count)
	if TEST_fail > 0 {
		os.exit(1)
	}
}
