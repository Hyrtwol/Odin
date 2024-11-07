#+build windows
package test_vendor_directx // generated by d3d12gen

import "core:testing"
import "vendor:directx/d3d12"

@(test)
verify_d3d12_types :: proc(t: ^testing.T) {
	// d3d12.h
	expect_size(t, d3d12.IUnknown, 8)
	expect_size(t, d3d12.LUID, 8)
	expect_size(t, d3d12.IID, 16)
	expect_size(t, d3d12.UUID, 16)
	expect_size(t, d3d12.GUID, 16)
	expect_size(t, d3d12.HANDLE, 8)
	expect_size(t, d3d12.HRESULT, 4)
	expect_size(t, d3d12.HWND, 8)
	expect_size(t, d3d12.HMODULE, 8)
	expect_size(t, d3d12.BOOL, 4)
	expect_size(t, d3d12.SIZE_T, 8)
	expect_size(t, d3d12.RECT, 16)
	// enum D3D_DRIVER_TYPE
	expect_value(t, d3d12.DRIVER_TYPE.UNKNOWN, 0x00000000)
	expect_value(t, d3d12.DRIVER_TYPE.HARDWARE, 0x00000001)
	// enum D3D12_PRIMITIVE_TOPOLOGY
	expect_value(t, d3d12.PRIMITIVE_TOPOLOGY.UNDEFINED, 0x00000000)
}

@(test)
verify_d3d12_constants :: proc(t: ^testing.T) {
	expect_value(t, d3d12.APPEND_ALIGNED_ELEMENT, 0xFFFFFFFF)
	expect_value(t, d3d12.ARRAY_AXIS_ADDRESS_RANGE_BIT_COUNT, 0x00000009)
	expect_value(t, d3d12.CLIP_OR_CULL_DISTANCE_COUNT, 0x00000008)
	expect_value(t, d3d12.CLIP_OR_CULL_DISTANCE_ELEMENT_COUNT, 0x00000002)
	expect_value(t, d3d12.DEFAULT_SHADER_4_COMPONENT_MAPPING, 0x00001688)
}

@(test)
verify_d3d12_helpers :: proc(t: ^testing.T) {
	expect_value(t, d3d12.ENCODE_SHADER_4_COMPONENT_MAPPING(0, 1, 2, 3), 0x00001688)
	expect_value(t, d3d12.DECODE_SHADER_4_COMPONENT_MAPPING(0, 0x00001688), 0x00000000)
	expect_value(t, d3d12.DECODE_SHADER_4_COMPONENT_MAPPING(1, 0x00001688), 0x00000001)
	expect_value(t, d3d12.DECODE_SHADER_4_COMPONENT_MAPPING(2, 0x00001688), 0x00000002)
	expect_value(t, d3d12.DECODE_SHADER_4_COMPONENT_MAPPING(3, 0x00001688), 0x00000003)
}
