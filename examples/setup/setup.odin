//+vet
package main

import "core:fmt"
import "core:os"

print_key_value :: proc(key: string, value: any) {
	fmt.printfln("  %-20s: %v", key, value)
}

main :: proc() {
	fmt.printfln("Setup %v %v %v %v \"%v\"", ODIN_VENDOR, ODIN_VERSION, ODIN_OS, ODIN_ARCH, ODIN_ROOT)
	exit_code: int = 0
	when ODIN_OS == .Windows {
		exit_code = setup_windows()
	} else {
		fmt.printfln("Sorry this tool don't do anything good on %v for now.", ODIN_OS)
		exit_code = 1
	}
	fmt.printfln("Done (%d)", exit_code)
	os.exit(exit_code)
}
