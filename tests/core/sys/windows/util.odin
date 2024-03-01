//+build windows
package test_core_sys_windows

import "core:testing"

@(private)
expect_size :: proc(t: ^testing.T, $act: typeid, exp: int, loc := #caller_location) -> bool {
	return testing.expectf(t, size_of(act) == exp, 
		"size_of(%v) should be %d was %d", typeid_of(act), exp, size_of(act), loc=loc)
}
