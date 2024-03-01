if "%VSCMD_ARG_TGT_ARCH%"=="" call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
@rem msbuild win32gen.vcxproj /p:configuration=Release /p:platform=x64
set genexe="x64\Release\win32gen.exe"
if exist %genexe% (
	del /f %genexe%
)
cl /c /Zi /nologo /W3 /WX- /diagnostics:column /sdl /O2 /Oi /GL /D NDEBUG /D _CONSOLE /D _UNICODE /D UNICODE /Gm- /EHsc /MD /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /std:c++20 /permissive- /Fo"win32gen\x64\Release\\" /Fd"win32gen\x64\Release\vc143.pdb" /external:W3 /Gd /TP /FC /errorReport:queue win32gen.cpp
if %ERRORLEVEL% equ 0 (
	link /ERRORREPORT:QUEUE /OUT:%genexe% /NOLOGO kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed /DEBUG /PDB:"x64\Release\win32gen.pdb" /SUBSYSTEM:CONSOLE /OPT:REF /OPT:ICF /LTCG:incremental /LTCGOUT:"win32gen\x64\Release\win32gen.iobj" /TLBID:1 /DYNAMICBASE /NXCOMPAT /IMPLIB:"x64\Release\win32gen.lib" /MACHINE:X64 win32gen\x64\Release\win32gen.obj
)
if %ERRORLEVEL% equ 0 (
	%genexe% ..\test_struct_sizes.odin
)
