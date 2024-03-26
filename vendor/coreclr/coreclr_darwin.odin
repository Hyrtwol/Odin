// +build darwin
package coreclr

import "core:sys/darwin"

// UNTESTED !!!!

LIBCORECLR :: "libcoreclr.dylib"
CORECLR_DIR :: "/usr/share/dotnet/shared/Microsoft.NETCore.App/8.0.2"
CORECLR_DLL :: CORECLR_DIR + "/" + LIBCORECLR
MAX_PATH :: 1024
