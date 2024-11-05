
#include "winres.h"

LANGUAGE LANG_ENGLISH, SUBLANG_ENGLISH_UK
#pragma code_page(65001)

#ifdef ICONFILE1
#define IDI_ICON1                       101
#endif
#ifdef ICONFILE2
#define IDI_ICON2                       102
#endif

#define Q(x) #x
#define QUOTE(x) Q(x)
#define FMTVER(x,y,z,w) QUOTE(x.y.z.w)

#ifndef V1
#define V1 1
#endif
#ifndef V2
#define V2 0
#endif
#ifndef V3
#define V3 0
#endif
#ifndef V4
#define V4 0
#endif
#ifndef ODIN_VERSION
#define ODIN_VERSION FMTVER(V1,V2,V3,V4)
#endif
#ifndef GIT_SHA
#define GIT_SHA _
#endif

VS_VERSION_INFO VERSIONINFO
 FILEVERSION V1,V2,V3,V4
 PRODUCTVERSION V1,V2,V3,V4
 FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
 FILEFLAGS 0x1L
#else
 FILEFLAGS 0x0L
#endif
 FILEOS 0x40004L
 FILETYPE 0x1L
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "080904b0"
        BEGIN
            VALUE "CompanyName", "https://odin-lang.org/"
            VALUE "FileDescription", FileDescription
            VALUE "FileVersion", FMTVER(V1,V2,V3,V4)
            VALUE "InternalName", Filename
            VALUE "LegalCopyright", "Copyright (c) 2016-2022 Ginger Bill. All rights reserved."
            VALUE "OriginalFilename", Filename
            VALUE "ProductName", ProductName
            VALUE "ProductVersion", QUOTE(ODIN_VERSION)
            VALUE "Comments", QUOTE(ODIN_VERSION)
			// PrivateBuild
			// SpecialBuild
			// custom values
            VALUE "GitSha", QUOTE(GIT_SHA)
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x809, 0x04b0
    END
END

#ifdef ICONFILE1
IDI_ICON1   ICON    QUOTE(ICONFILE1)
#endif
#ifdef ICONFILE2
IDI_ICON2   ICON    QUOTE(ICONFILE2)
#endif