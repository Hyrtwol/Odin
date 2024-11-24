@echo off
setlocal enabledelayedexpansion
if "%VSCMD_ARG_TGT_ARCH%"=="" call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
pushd %~dp0..\..
@echo on
odin run examples/setup -resource:examples/setup/setup.rc -vet -strict-style -- %*
@echo off
popd
