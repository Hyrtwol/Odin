#+vet
package main

import "core:fmt"
import "core:os"

print_key_value :: proc(key: string, value: any) {
	fmt.printfln("  %-20s: %v", key, value)
}

main :: proc() {
	fmt.println("[Odin Setup]")
	print_key_value("ODIN_VENDOR", ODIN_VENDOR)
	print_key_value("ODIN_VERSION", ODIN_VERSION)
	print_key_value("ODIN_OS", ODIN_OS)
	print_key_value("ODIN_ARCH", ODIN_ARCH)
	print_key_value("ODIN_ROOT", ODIN_ROOT)

	exit_code: int = 0
	when ODIN_OS == .Windows {
		exit_code = setup_windows()
	} else {
		fmt.printfln("Sorry this tool don't do anything good on %v for now.", ODIN_OS)
		exit_code = 1
	}
	//dump_icon()
	os.exit(exit_code)
}
