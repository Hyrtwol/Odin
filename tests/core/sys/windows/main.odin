//+build windows
package test_core_sys_windows

import "core:testing"
import "core:fmt"
import "core:os"

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

main :: proc() {
	verify_gdi32_struct_sizes(t)
	verify_winmm_struct_sizes(t)

	if TEST_fail > 0 {
		os.exit(1)
	}
}
