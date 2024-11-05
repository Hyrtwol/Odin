package directx_d3d12

D3D12_ENCODE_SHADER_4_COMPONENT_MAPPING :: proc "contextless" (Src0, Src1, Src2, Src3: u32) -> u32 {
	D3D12_SHADER_COMPONENT_MAPPING_ALWAYS_SET_BIT_AVOIDING_ZEROMEM_MISTAKES :: (1 << (SHADER_COMPONENT_MAPPING_SHIFT * 4))
	return (
		(Src0 & SHADER_COMPONENT_MAPPING_MASK) |
		((Src1 & SHADER_COMPONENT_MAPPING_MASK) << SHADER_COMPONENT_MAPPING_SHIFT) |
		((Src2 & SHADER_COMPONENT_MAPPING_MASK) << (SHADER_COMPONENT_MAPPING_SHIFT * 2)) |
		((Src3 & SHADER_COMPONENT_MAPPING_MASK) << (SHADER_COMPONENT_MAPPING_SHIFT * 3)) |
		D3D12_SHADER_COMPONENT_MAPPING_ALWAYS_SET_BIT_AVOIDING_ZEROMEM_MISTAKES)
}

D3D12_DECODE_SHADER_4_COMPONENT_MAPPING :: proc "contextless" (ComponentToExtract, Mapping: u32) -> SHADER_COMPONENT_MAPPING {
	return ((SHADER_COMPONENT_MAPPING)(Mapping >> (SHADER_COMPONENT_MAPPING_SHIFT * ComponentToExtract) & SHADER_COMPONENT_MAPPING_MASK))
}

// D:\dev\malerion\packages\Microsoft.Direct3D.D3D12.1.614.1\build\native\include\d3dx12\d3dx12_resource_helpers.h

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

// include\d3dx12\d3dx12_resource_helpers.h#225

// Heap-allocating UpdateSubresources implementation

/*
inline UINT64 UpdateSubresources(
    pCmdList: ^IGraphicsCommandList,
    pDestinationResource: ^IResource,
    pIntermediate: ^IResource,
    IntermediateOffset: u64,
    FirstSubresource: u32,
    NumSubresources: u32,
	pSrcData: ^D3D12_SUBRESOURCE_DATA)
{
	RequiredSize : u64 = 0;
    const auto MemToAlloc = static_cast<UINT64>(sizeof(D3D12_PLACED_SUBRESOURCE_FOOTPRINT) + sizeof(UINT) + sizeof(UINT64)) * NumSubresources;
    if MemToAlloc > SIZE_MAX {
       return 0
    }
    void* pMem = HeapAlloc(GetProcessHeap(), 0, static_cast<SIZE_T>(MemToAlloc));
	// pMem := win32.HeapAlloc(win32.GetProcessHeap(), 0, uint(MemToAlloc))
    if pMem == nil {
       return 0
    }
    auto pLayouts = static_cast<D3D12_PLACED_SUBRESOURCE_FOOTPRINT*>(pMem);
    auto pRowSizesInBytes = reinterpret_cast<UINT64*>(pLayouts + NumSubresources);
    auto pNumRows = reinterpret_cast<UINT*>(pRowSizesInBytes + NumSubresources);

#if defined(_MSC_VER) || !defined(_WIN32)
    const auto Desc = pDestinationResource->GetDesc();
#else
    D3D12_RESOURCE_DESC tmpDesc;
    const auto& Desc = *pDestinationResource->GetDesc(&tmpDesc);
#endif
    ID3D12Device* pDevice = nullptr;
    pDestinationResource->GetDevice(IID_ID3D12Device, reinterpret_cast<void**>(&pDevice));
    pDevice->GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, pLayouts, pNumRows, pRowSizesInBytes, &RequiredSize);
    pDevice->Release();

    const UINT64 Result = UpdateSubresources(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, pLayouts, pNumRows, pRowSizesInBytes, pSrcData);
    HeapFree(GetProcessHeap(), 0, pMem);
	// win32.HeapFree(win32.GetProcessHeap(), 0, pMem)
    return Result;
}
*/
