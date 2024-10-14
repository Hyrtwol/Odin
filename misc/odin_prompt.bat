@set arch=x64
@set vsroot=%ProgramFiles%\Microsoft Visual Studio\2022\Community
@Title Odin Command Prompt - %~n1
@rem call "%vsroot%\Common7\Tools\VsDevCmd.bat"
@if "%VSCMD_ARG_TGT_ARCH%"=="" call "%vsroot%\VC\Auxiliary\Build\vcvarsall.bat" %arch%
@cd /d %1
@prompt "$P"$_$G
