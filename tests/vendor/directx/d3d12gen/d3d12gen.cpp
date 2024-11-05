#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <timeapi.h>
#include <mmeapi.h>
#include <windns.h>
#include <commdlg.h>
#include <winver.h>
#include <shobjidl.h>
#include <shellapi.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <wincrypt.h>

#include <windows.h>
#include <wrl.h>
#include <d3d12.h>
#include <D3Dcompiler.h>
#include <DirectXMath.h>
#include <DirectXPackedVector.h>
#include <DirectXColors.h>
#include <DirectXCollision.h>
#include <string>
#include <memory>
#include <algorithm>
#include <vector>
#include <array>
#include <unordered_map>
#include <cstdint>
#include <fstream>
#include <sstream>
#include <iostream>
#include <cassert>

#define sut "d3d12"
#define trim_count 6
#include "..\..\..\..\misc\testgen\odintestgen.h"

static void verify_d3d12_types(ofstream& out) {
	test_proc_begin();
	test_proc_comment("d3d12.h");

	expect_size(IUnknown);
	expect_size(LUID);
	expect_size(IID);
	expect_size(UUID);
	expect_size(GUID);
	expect_size(HANDLE);
	expect_size(HRESULT);
	expect_size(HWND);
	expect_size(HMODULE);
	expect_size(BOOL);
	expect_size(SIZE_T);
	expect_size(RECT);

	test_proc_comment("enum D3D_DRIVER_TYPE");
	expect_value_enum_remap("DRIVER_TYPE", "UNKNOWN", D3D_DRIVER_TYPE_UNKNOWN);
	expect_value_enum_remap("DRIVER_TYPE", "HARDWARE", D3D_DRIVER_TYPE_HARDWARE);

	test_proc_comment("enum D3D12_PRIMITIVE_TOPOLOGY");
	expect_value_enum_remap("PRIMITIVE_TOPOLOGY", "UNDEFINED", D3D_PRIMITIVE_TOPOLOGY_UNDEFINED);

	test_proc_end();
}

static void verify_d3d12_constants(ofstream& out) {
	test_proc_begin();

	expect_value_trim(D3D12_APPEND_ALIGNED_ELEMENT);
	expect_value_trim(D3D12_ARRAY_AXIS_ADDRESS_RANGE_BIT_COUNT);
	expect_value_trim(D3D12_CLIP_OR_CULL_DISTANCE_COUNT);
	expect_value_trim(D3D12_CLIP_OR_CULL_DISTANCE_ELEMENT_COUNT);

	expect_value_trim(D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING);
	test_proc_end();
}

static void verify_d3d12_helpers(ofstream& out) {
	test_proc_begin();

	expect_value(D3D12_ENCODE_SHADER_4_COMPONENT_MAPPING(0, 1, 2, 3));
	expect_value(D3D12_DECODE_SHADER_4_COMPONENT_MAPPING(0, 0x00001688));
	expect_value(D3D12_DECODE_SHADER_4_COMPONENT_MAPPING(1, 0x00001688));
	expect_value(D3D12_DECODE_SHADER_4_COMPONENT_MAPPING(2, 0x00001688));
	expect_value(D3D12_DECODE_SHADER_4_COMPONENT_MAPPING(3, 0x00001688));

	test_proc_end();
}

static void test_vendor_directx(ofstream& out) {
	out << "#+build windows" << endl
		<< "package " << __func__
		<< " // generated by " << path(__FILE__).filename().replace_extension("").string() << endl
		<< endl
		<< "import \"core:testing\"" << endl
		<< "import \"vendor:directx/d3d12\"" << endl;

	verify_d3d12_types(out);
	verify_d3d12_constants(out);
	verify_d3d12_helpers(out);
}

int main(int argc, char* argv[]) {
	if (argc < 2) { cout << "Usage: " << path(argv[0]).filename().string() << " <odin-output-file>" << endl; return -1; }
	auto filepath = path(argv[1]);
	cout << "Writing " << filepath.string() << endl;
	ofstream out(filepath);
	test_vendor_directx(out);
	out.close();
}