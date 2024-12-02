#+build windows
// <D:\dev\malerion\packages\Microsoft.Direct3D.D3D12.1.614.1\build\native\include\d3dx12\d3dx12_resource_helpers.h>
package directx_d3d12

//import "../dxgi"
import "base:intrinsics"
import "base:runtime"
import "core:c"
import "core:slice"
import win32 "core:sys/windows"

UINT :: u32
UINT64 :: u64
LONG_PTR :: win32.LONG_PTR
SIZE_MAX :: c.SIZE_MAX

// template <typename T, typename U, typename V>
// inline void D3D12DecomposeSubresource( UINT Subresource, UINT MipLevels, UINT ArraySize, _Out_ T& MipSlice, _Out_ U& ArraySlice, _Out_ V& PlaneSlice ) {
//     MipSlice = static_cast<T>(Subresource % MipLevels);
//     ArraySlice = static_cast<U>((Subresource / MipLevels) % ArraySize);
//     PlaneSlice = static_cast<V>(Subresource / (MipLevels * ArraySize));
// }

// Row-by-row memcpy
//
// <https://github.com/microsoft/DirectX-Headers/blob/main/include/directx/d3dx12_resource_helpers.h#L28>
MemcpySubresource1 :: #force_inline proc "contextless" (
	pDest: ^MEMCPY_DEST,
	pSrc: ^SUBRESOURCE_DATA,
	RowSizeInBytes: SIZE_T,
	NumRows, NumSlices: u32,
) {
	row_size := int(RowSizeInBytes)
	for z in 0..< int(NumSlices) {
		pDestSlice := uintptr(pDest.pData) + uintptr(int(pDest.SlicePitch) * z)
		pSrcSlice := uintptr(pSrc.pData) + uintptr(int(pSrc.SlicePitch) * z)
		for y in 0 ..< int(NumRows) {
			runtime.mem_copy(
				rawptr(pDestSlice + uintptr(int(pDest.RowPitch) * y)),
				rawptr(pSrcSlice + uintptr(int(pSrc.RowPitch) * y)),
				row_size)
		}
	}
}

// Row-by-row memcpy
//
// <https://github.com/microsoft/DirectX-Headers/blob/main/include/directx/d3dx12_resource_helpers.h#L50>
MemcpySubresource2 :: #force_inline proc "contextless" (
	pDest: ^MEMCPY_DEST,
	pResourceData: rawptr,
	pSrc: ^SUBRESOURCE_INFO,
	RowSizeInBytes: SIZE_T,
	NumRows, NumSlices: u32,
) {
	row_size := int(RowSizeInBytes)
	for z in 0..< int(NumSlices) {
		pDestSlice := uintptr(pDest.pData) + uintptr(int(pDest.SlicePitch) * z)
		pSrcSlice := uintptr(pResourceData) + uintptr(int(pSrc.Offset) + int(pSrc.DepthPitch) * z)
		for y in 0 ..< int(NumRows) {
			runtime.mem_copy(
				rawptr(pDestSlice + uintptr(int(pDest.RowPitch) * y)),
				rawptr(pSrcSlice + uintptr(int(pSrc.RowPitch) * y)),
				row_size)
		}
	}
}

// MemcpySubresource :: proc {
// 	MemcpySubresource1,
// 	MemcpySubresource2,
// }


// Returns required size of a buffer to be used for data upload
//
// <https://github.com/microsoft/DirectX-Headers/blob/main/include/directx/d3dx12_resource_helpers.h#L73>
GetRequiredIntermediateSize :: proc "contextless" (pDestinationResource: ^IResource, FirstSubresource, NumSubresources: u32) -> u64 {
	RequiredSize: u64 = 0
	desc, tmpDesc: RESOURCE_DESC
	desc = pDestinationResource->GetDesc(&tmpDesc)^
	pDevice: ^IDevice = nil
	pDestinationResource->GetDevice(IDevice_UUID, (^rawptr)(&pDevice))
	pDevice->GetCopyableFootprints(&desc, FirstSubresource, NumSubresources, 0, nil, nil, nil, &RequiredSize)
	pDevice->Release()
	return RequiredSize
}

// All arrays must be populated (e.g. by calling GetCopyableFootprints)
//
// <https://github.com/microsoft/DirectX-Headers/blob/main/include/directx/d3dx12_resource_helpers.h#L96>
//@(private = "file")
UpdateSubresources1 :: proc "contextless" (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	FirstSubresource: u32,
	NumSubresources: u32,
	RequiredSize: u64,
	pLayouts: ^PLACED_SUBRESOURCE_FOOTPRINT,
	pNumRows: ^u32,
	pRowSizesInBytes: ^u64,
	pSrcData: ^SUBRESOURCE_DATA,
) -> u64 {
	// Minor validation

	layouts := slice.from_ptr(pLayouts, int(NumSubresources))
	numRows := slice.from_ptr(pNumRows, int(NumSubresources))
	rowSizesInBytes := slice.from_ptr(pRowSizesInBytes, int(NumSubresources))
	srcData := slice.from_ptr(pSrcData, int(NumSubresources))

	tmpDesc1, tmpDesc2: RESOURCE_DESC
	IntermediateDesc := pIntermediate->GetDesc(&tmpDesc1)^
	DestinationDesc := pDestinationResource->GetDesc(&tmpDesc2)^

	if IntermediateDesc.Dimension != .BUFFER ||
	   IntermediateDesc.Width < RequiredSize + layouts[0].Offset ||
	   RequiredSize > UINT64(~SIZE_T(0)) ||
	   (DestinationDesc.Dimension == .BUFFER && (FirstSubresource != 0 || NumSubresources != 1)) {
		return 0
	}

	// BYTE* pData;
	// HRESULT hr = pIntermediate->Map(0, nullptr, reinterpret_cast<void**>(&pData));
	pData: ^u8
	hr: HRESULT = pIntermediate->Map(0, nil, cast(^rawptr)(&pData))
	if win32.FAILED(hr) {
		return 0
	}

	for i: UINT = 0; i < NumSubresources; i += 1 {
		if rowSizesInBytes[i] > UINT64(~SIZE_T(0)) {return 0}
		DestData := MEMCPY_DEST{
			pData = rawptr(uintptr(pData) + uintptr(layouts[i].Offset)),
			RowPitch = SIZE_T(layouts[i].Footprint.RowPitch),
			SlicePitch = SIZE_T(layouts[i].Footprint.RowPitch) * SIZE_T(numRows[i]),
		}
		MemcpySubresource1(&DestData, &srcData[i], cast(SIZE_T)(rowSizesInBytes[i]), numRows[i], layouts[i].Footprint.Depth)
	}
	pIntermediate->Unmap(0, nil)

	// if (DestinationDesc.Dimension == D3D12_RESOURCE_DIMENSION_BUFFER)
	// {
	// 	pCmdList->CopyBufferRegion(
	// 		pDestinationResource, 0, pIntermediate, pLayouts[0].Offset, pLayouts[0].Footprint.Width);
	// }
	// else
	// {
	// 	for (UINT i = 0; i < NumSubresources; ++i)
	// 	{
	// 		const CD3DX12_TEXTURE_COPY_LOCATION Dst(pDestinationResource, i + FirstSubresource);
	// 		const CD3DX12_TEXTURE_COPY_LOCATION Src(pIntermediate, pLayouts[i]);
	// 		pCmdList->CopyTextureRegion(&Dst, 0, 0, 0, &Src, nullptr);
	// 	}
	// }
	if DestinationDesc.Dimension == .BUFFER {
		pCmdList->CopyBufferRegion(pDestinationResource, 0, pIntermediate, layouts[0].Offset, u64(layouts[0].Footprint.Width))
	} else {
		for i: UINT = 0; i < NumSubresources; i += 1 {
			// const CD3DX12_TEXTURE_COPY_LOCATION Dst(pDestinationResource, i + FirstSubresource);
			// const CD3DX12_TEXTURE_COPY_LOCATION Src(pIntermediate, pLayouts[i]);
			Dst := TEXTURE_COPY_LOCATION {
				pResource        = pDestinationResource,
				Type             = .SUBRESOURCE_INDEX,
				SubresourceIndex = i + FirstSubresource,
			}
			Src := TEXTURE_COPY_LOCATION {
				pResource       = pIntermediate,
				Type            = .PLACED_FOOTPRINT,
				PlacedFootprint = layouts[i],
			}
			pCmdList->CopyTextureRegion(&Dst, 0, 0, 0, &Src, nil)
		}
	}
	return RequiredSize
}

// include\d3dx12\d3dx12_resource_helpers.h#160

// All arrays must be populated (e.g. by calling GetCopyableFootprints)
UpdateSubresources2 :: proc "contextless" (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	FirstSubresource: UINT,
	NumSubresources: UINT,
	RequiredSize: UINT64,
	pLayouts: ^PLACED_SUBRESOURCE_FOOTPRINT,
	pNumRows: ^UINT,
	pRowSizesInBytes: ^UINT64,
	pResourceData: rawptr,
	pSrcData: ^SUBRESOURCE_INFO,
) -> u64 {
	// Minor validation

	layouts := slice.from_ptr(pLayouts, int(NumSubresources))
	numRows := slice.from_ptr(pNumRows, int(NumSubresources))
	rowSizesInBytes := slice.from_ptr(pRowSizesInBytes, int(NumSubresources))
	srcData := slice.from_ptr(pSrcData, int(NumSubresources))

	tmpDesc1, tmpDesc2: RESOURCE_DESC
	IntermediateDesc := pIntermediate->GetDesc(&tmpDesc1)^
	DestinationDesc := pDestinationResource->GetDesc(&tmpDesc2)^

	if IntermediateDesc.Dimension != .BUFFER ||
	   IntermediateDesc.Width < RequiredSize + layouts[0].Offset ||
	   RequiredSize > UINT64(~SIZE_T(0)) ||
	   (DestinationDesc.Dimension == .BUFFER && (FirstSubresource != 0 || NumSubresources != 1)) {
		return 0
	}

	pData: ^u8
	hr: HRESULT = pIntermediate->Map(0, nil, cast(^rawptr)(&pData))
	if win32.FAILED(hr) {
		return 0
	}

	for i: UINT = 0; i < NumSubresources; i += 1 {
		//if (pRowSizesInBytes[i] > SIZE_T(-1)) {return 0}
		if (rowSizesInBytes[i] > UINT64(~SIZE_T(0))) {return 0}
		DestData := MEMCPY_DEST{
			pData = rawptr(uintptr(pData) + uintptr(layouts[i].Offset)),
			RowPitch = SIZE_T(layouts[i].Footprint.RowPitch),
			SlicePitch = SIZE_T(layouts[i].Footprint.RowPitch) * SIZE_T(numRows[i]),
		}
		MemcpySubresource2(&DestData, pResourceData, &srcData[i], cast(SIZE_T)(rowSizesInBytes[i]), numRows[i], layouts[i].Footprint.Depth)
	}
	pIntermediate->Unmap(0, nil)

	if DestinationDesc.Dimension == .BUFFER {
		pCmdList->CopyBufferRegion(pDestinationResource, 0, pIntermediate, layouts[0].Offset, u64(layouts[0].Footprint.Width))
	} else {
		for i: UINT = 0; i < NumSubresources; i += 1 {
			// const CD3DX12_TEXTURE_COPY_LOCATION Dst(pDestinationResource, i + FirstSubresource);
			// const CD3DX12_TEXTURE_COPY_LOCATION Src(pIntermediate, pLayouts[i]);
			Dst := TEXTURE_COPY_LOCATION {
				pResource        = pDestinationResource,
				Type             = .SUBRESOURCE_INDEX,
				SubresourceIndex = i + FirstSubresource,
			}
			Src := TEXTURE_COPY_LOCATION {
				pResource       = pIntermediate,
				Type            = .PLACED_FOOTPRINT,
				PlacedFootprint = layouts[i],
			}
			pCmdList->CopyTextureRegion(&Dst, 0, 0, 0, &Src, nil)
		}
	}
	return RequiredSize
}

// include\d3dx12\d3dx12_resource_helpers.h#225

// Heap-allocating UpdateSubresources implementation
//@(private = "file")
//UpdateSubresources3 :: proc "contextless" (
UpdateSubresources3 :: proc (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	IntermediateOffset: u64,
	FirstSubresource: u32,
	NumSubresources: u32,
	pSrcData: ^SUBRESOURCE_DATA,
) -> u64 {
	RequiredSize: u64 = 0
	MemToAlloc := cast(UINT64)((size_of(PLACED_SUBRESOURCE_FOOTPRINT) + size_of(UINT) + size_of(UINT64)) * int(NumSubresources))
	if MemToAlloc > UINT64(SIZE_MAX) {
		panic("MemToAlloc > UINT64(SIZE_MAX)") // return 0
	}
	pMem: rawptr = win32.HeapAlloc(win32.GetProcessHeap(), 0, cast(SIZE_T)(MemToAlloc)) // TODO Odinify
	if pMem == nil {
		panic("pMem == nil") // return 0
	}
	pLayouts := cast(^PLACED_SUBRESOURCE_FOOTPRINT)(pMem)
	//pRowSizesInBytes : ^UINT64 = cast(^UINT64)(uintptr(pLayouts) + uintptr(NumSubresources))
	pRowSizesInBytes : ^UINT64 = cast(^UINT64)intrinsics.ptr_offset(pLayouts, int(NumSubresources))
	//pNumRows : ^UINT = cast(^UINT)(uintptr(pRowSizesInBytes) + uintptr(NumSubresources))
	pNumRows : ^UINT = cast(^UINT)intrinsics.ptr_offset(pRowSizesInBytes, int(NumSubresources))

	Desc, tmpDesc: RESOURCE_DESC
	Desc = pDestinationResource->GetDesc(&tmpDesc)^

	pDevice: ^IDevice = nil
	// pDestinationResource->GetDevice(IID_ID3D12Device, reinterpret_cast<void**>(&pDevice));
	pDestinationResource->GetDevice(IDevice_UUID, (^rawptr)(&pDevice))
	pDevice->GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, pLayouts, pNumRows, pRowSizesInBytes, &RequiredSize)
	pDevice->Release()

	Result := UpdateSubresources1(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, pLayouts, pNumRows, pRowSizesInBytes, pSrcData)
	// HeapFree(GetProcessHeap(), 0, pMem);
	win32.HeapFree(win32.GetProcessHeap(), 0, pMem)
	return Result
}

// include\d3dx12\d3dx12_resource_helpers.h#267

// Heap-allocating UpdateSubresources implementation
UpdateSubresources4 :: proc "contextless" (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	IntermediateOffset: UINT64,
	FirstSubresource: UINT,
	NumSubresources: UINT,
	pResourceData: rawptr,
	pSrcData: ^SUBRESOURCE_INFO,
) -> UINT64 {
	RequiredSize: UINT64 = 0
	MemToAlloc: UINT64 = cast(UINT64)((size_of(PLACED_SUBRESOURCE_FOOTPRINT) + size_of(UINT) + size_of(UINT64)) * int(NumSubresources))
	if MemToAlloc > UINT64(SIZE_MAX) {
		return 0
	}
	pMem: rawptr = win32.HeapAlloc(win32.GetProcessHeap(), 0, cast(SIZE_T)(MemToAlloc)) // TODO Odinify
	if pMem == nil {
		return 0
	}
	pLayouts := cast(^PLACED_SUBRESOURCE_FOOTPRINT)(pMem)
	// pRowSizesInBytes := cast(^UINT64)(uintptr(pLayouts) + uintptr(NumSubresources))
	// pNumRows := cast(^UINT)(uintptr(pRowSizesInBytes) + uintptr(NumSubresources))
	pRowSizesInBytes : ^UINT64 = cast(^UINT64)intrinsics.ptr_offset(pLayouts, int(NumSubresources))
	pNumRows : ^UINT = cast(^UINT)intrinsics.ptr_offset(pRowSizesInBytes,int(NumSubresources))

	Desc, tmpDesc: RESOURCE_DESC
	Desc = pDestinationResource->GetDesc(&tmpDesc)^
	// ID3D12Device* pDevice = nullptr;
	pDevice: ^IDevice = nil
	//pDestinationResource->GetDevice(IID_ID3D12Device, reinterpret_cast<void**>(&pDevice));
	pDestinationResource->GetDevice(IDevice_UUID, (^rawptr)(&pDevice))
	pDevice->GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, pLayouts, pNumRows, pRowSizesInBytes, &RequiredSize)
	pDevice->Release()

	Result := UpdateSubresources2(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, pLayouts, pNumRows, pRowSizesInBytes, pResourceData, pSrcData)
	//HeapFree(GetProcessHeap(), 0, pMem);
	win32.HeapFree(win32.GetProcessHeap(), 0, pMem)
	return Result
}

/*

// include\d3dx12\d3dx12_resource_helpers.h#310

// Stack-allocating UpdateSubresources implementation
// template <UINT MaxSubresources>
UpdateSubresources310 :: proc "contextless" (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	IntermediateOffset: UINT64,
	FirstSubresource: UINT,
	NumSubresources: UINT,
	pSrcData: ^SUBRESOURCE_DATA,
) -> UINT64 {
	RequiredSize: UINT64 = 0
	Layouts: [MaxSubresources]PLACED_SUBRESOURCE_FOOTPRINT
	NumRows: [MaxSubresources]UINT
	RowSizesInBytes: [MaxSubresources]UINT64

	desc, tmpDesc: RESOURCE_DESC
	desc = pDestinationResource->GetDesc(&tmpDesc)^
	//ID3D12Device* pDevice = nullptr;
	pDevice: ^IDevice = nil
	//pDestinationResource->GetDevice(IID_ID3D12Device, reinterpret_cast<void**>(&pDevice));
	pDestinationResource->GetDevice(IDevice_UUID, (^rawptr)(&pDevice))
	pDevice->GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, Layouts, NumRows, RowSizesInBytes, &RequiredSize)
	pDevice->Release()

	return UpdateSubresources(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, Layouts, NumRows, RowSizesInBytes, pSrcData)
}

// include\d3dx12\d3dx12_resource_helpers.h#341

// Stack-allocating UpdateSubresources implementation
//template <UINT MaxSubresources>
MaxSubresources :: 4
UpdateSubresources341 :: proc "contextless" (
	pCmdList: ^IGraphicsCommandList,
	pDestinationResource: ^IResource,
	pIntermediate: ^IResource,
	IntermediateOffset: UINT64,
	FirstSubresource: UINT,
	NumSubresources: UINT,
	pResourceData: rawptr,
	pSrcData: ^SUBRESOURCE_INFO,
) -> UINT64 {
	RequiredSize: UINT64 = 0
	Layouts: PLACED_SUBRESOURCE_FOOTPRINT[MaxSubresources]
	NumRows: [MaxSubresources]UINT
	RowSizesInBytes: [MaxSubresources]UINT64

	desc, tmpDesc: RESOURCE_DESC
	desc = pDestinationResource->GetDesc(&tmpDesc)^
	pDevice: ^IDevice = nil
	// pDestinationResource->GetDevice(IID_ID3D12Device, reinterpret_cast<void**>(&pDevice));
	pDestinationResource->GetDevice(IDevice_UUID, (^rawptr)(&pDevice))
	pDevice->GetCopyableFootprints(&desc, FirstSubresource, NumSubresources, IntermediateOffset, &Layouts, &NumRows, &RowSizesInBytes, &RequiredSize)
	pDevice->Release()

	return UpdateSubresources(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, Layouts, NumRows, RowSizesInBytes, pResourceData, pSrcData)
}

*/

// include\d3dx12\d3dx12_resource_helpers.h#372

IsLayoutOpaque :: #force_inline proc "contextless" (Layout: TEXTURE_LAYOUT) -> bool {
	return Layout == .UNKNOWN || Layout == ._64KB_UNDEFINED_SWIZZLE
}

// include\d3dx12\d3dx12_resource_helpers.h#376
// include\d3dx12\d3dx12_resource_helpers.h#389
// include\d3dx12\d3dx12_resource_helpers.h#396

when D3D12_SDK_VERSION >= 606 {

	// include\d3dx12\d3dx12_resource_helpers.h#407
	// include\d3dx12\d3dx12_resource_helpers.h#558
	// include\d3dx12\d3dx12_resource_helpers.h#579

}

// UpdateSubresources :: proc {
// 	UpdateSubresources1,
// 	UpdateSubresources2,
// 	UpdateSubresources3,
// 	UpdateSubresources4,
// }
