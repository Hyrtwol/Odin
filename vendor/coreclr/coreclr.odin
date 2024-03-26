/*
Core Common Language Runtime (CLR)

Inspired by "Embedding CoreCLR in your C/C++ application"
https://yizhang82.dev/hosting-coreclr

https://learn.microsoft.com/en-us/dotnet/standard/clr
https://github.com/dotnet/runtime
https://github.com/dotnet/runtime/blob/main/docs/design/features/native-hosting.md
https://github.com/dotnet/runtime/blob/main/src/coreclr/hosts/inc/coreclrhost.h
https://github.com/dotnet/runtime/blob/main/src/native/corehost/coreclr_delegates.h
https://github.com/dotnet/runtime/blob/main/src/native/corehost/hostfxr.h

https://github.com/dotnet/samples/tree/main/core/hosting
https://github.com/renkun-ken/cpp-coreclr
https://github.com/dotnet/samples/blob/main/core/hosting/src/NativeHost/nativehost.cpp
*/
package coreclr

import _c "core:c"

char_t :: _c.wchar_t
size_t :: _c.size_t
int32_t :: _c.int32_t
int64_t :: _c.int64_t
