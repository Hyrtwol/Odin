//+build windows
package test_core_sys_windows

import "core:testing"
import win32 "core:sys/windows"

@(test)
verify_arc_direction :: proc(t: ^testing.T) {
	testing.expect_value(t, 1, int(win32.ArcDirection.AD_COUNTERCLOCKWISE))
	testing.expect_value(t, 2, int(win32.ArcDirection.AD_CLOCKWISE))
}
