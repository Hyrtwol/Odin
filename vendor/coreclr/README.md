# CoreCLR

* https://github.com/dotnet/runtime/blob/main/src/native/corehost/coreclr_delegates.h
* https://github.com/dotnet/runtime/blob/main/src/native/corehost/hostpolicy/coreclr.h
* https://github.com/dotnet/runtime/blob/main/src/native/corehost/hostfxr.h
* https://github.com/dotnet/runtime/blob/main/src/coreclr/hosts/inc/coreclrhost.h
* https://yizhang82.dev/hosting-coreclr
* https://github.com/renkun-ken/cpp-coreclr

to list dotnet runtimes use:

```sh
dotnet --list-runtimes
```

ilasm.exe is from runtime.win-x64.microsoft.netcore.ilasm.8.0.0.nupkg
ildasm.exe is from runtime.win-x64.microsoft.netcore.ildasm.8.0.0.nupkg

```c
#ifdef __linux__
const string libcoreclr = "libcoreclr.so";
#elif __APPLE__
const string libcoreclr = "libcoreclr.dylib";
#else
const string libcoreclr = "coreclr.dll";
#endif
```
