// +build linux
package coreclr

import "core:sys/linux"

// UNTESTED !!!!

LIBCORECLR :: "libcoreclr.so"
CORECLR_DIR :: "/usr/share/dotnet/shared/Microsoft.NETCore.App/8.0.2"
CORECLR_DLL :: CORECLR_DIR + "/" + LIBCORECLR
MAX_PATH :: 1024
