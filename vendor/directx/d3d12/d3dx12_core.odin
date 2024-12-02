#+build windows
// D:\dev\malerion\packages\Microsoft.Direct3D.D3D12.1.614.1\build\native\include\d3dx12\d3dx12_core.h
package directx_d3d12

// import "base:intrinsics"
// import "base:runtime"
// import "core:c"
// import "core:slice"
// import win32 "core:sys/windows"

/*
struct CD3DX12_SHADER_BYTECODE : public D3D12_SHADER_BYTECODE
{
    CD3DX12_SHADER_BYTECODE() = default;
    explicit CD3DX12_SHADER_BYTECODE(const D3D12_SHADER_BYTECODE &o) noexcept :
        D3D12_SHADER_BYTECODE(o)
    {}
    CD3DX12_SHADER_BYTECODE(
        _In_ ID3DBlob* pShaderBlob ) noexcept
    {
        pShaderBytecode = pShaderBlob->GetBufferPointer();
        BytecodeLength = pShaderBlob->GetBufferSize();
    }
    CD3DX12_SHADER_BYTECODE(
        const void* _pShaderBytecode,
        SIZE_T bytecodeLength ) noexcept
    {
        pShaderBytecode = _pShaderBytecode;
        BytecodeLength = bytecodeLength;
    }
};
*/

CD3DX12_SHADER_BYTECODE :: proc(pShaderBlob: ^IBlob) -> SHADER_BYTECODE {
	return {
		pShaderBytecode = pShaderBlob->GetBufferPointer(),
		BytecodeLength = pShaderBlob->GetBufferSize(),
	}
}

/*
struct CD3DX12_RASTERIZER_DESC : public D3D12_RASTERIZER_DESC
{
    explicit CD3DX12_RASTERIZER_DESC( CD3DX12_DEFAULT ) noexcept
    {
        FillMode = D3D12_FILL_MODE_SOLID;
        CullMode = D3D12_CULL_MODE_BACK;
        FrontCounterClockwise = FALSE;
        DepthBias = D3D12_DEFAULT_DEPTH_BIAS;
        DepthBiasClamp = D3D12_DEFAULT_DEPTH_BIAS_CLAMP;
        SlopeScaledDepthBias = D3D12_DEFAULT_SLOPE_SCALED_DEPTH_BIAS;
        DepthClipEnable = TRUE;
        MultisampleEnable = FALSE;
        AntialiasedLineEnable = FALSE;
        ForcedSampleCount = 0;
        ConservativeRaster = D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF;
    }
};
*/

CD3DX12_RASTERIZER_DESC_DEFAULT := RASTERIZER_DESC {
	FillMode = .SOLID,
	CullMode = .BACK,
	FrontCounterClockwise = false,
	DepthBias = 0,
	DepthBiasClamp = 0,
	SlopeScaledDepthBias = 0,
	DepthClipEnable = true,
	MultisampleEnable = false,
	AntialiasedLineEnable = false,
	ForcedSampleCount = 0,
	ConservativeRaster = .OFF,
}

/*
    explicit CD3DX12_HEAP_PROPERTIES(
        D3D12_HEAP_TYPE type,
        UINT creationNodeMask = 1,
        UINT nodeMask = 1 ) noexcept
    {
        Type = type;
        CPUPageProperty = D3D12_CPU_PAGE_PROPERTY_UNKNOWN;
        MemoryPoolPreference = D3D12_MEMORY_POOL_UNKNOWN;
        CreationNodeMask = creationNodeMask;
        VisibleNodeMask = nodeMask;
    }
*/

CD3DX12_HEAP_PROPERTIES :: proc(
	type: HEAP_TYPE,
	creationNodeMask: UINT = 1,
	nodeMask: UINT = 1,
) -> HEAP_PROPERTIES {
	return HEAP_PROPERTIES {
		Type = type,
        CPUPageProperty = .UNKNOWN,
        MemoryPoolPreference = .UNKNOWN,
        CreationNodeMask = creationNodeMask,
        VisibleNodeMask = nodeMask,
	}
}

/*
    static inline CD3DX12_RESOURCE_DESC Buffer(
        UINT64 width,
        D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE,
        UINT64 alignment = 0 ) noexcept
    {
        return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_BUFFER, alignment, width, 1, 1, 1,
            DXGI_FORMAT_UNKNOWN, 1, 0, D3D12_TEXTURE_LAYOUT_ROW_MAJOR, flags );
    }
*/
CD3DX12_RESOURCE_DESC_BUFFER :: proc(
	width : UINT64,
	flags : RESOURCE_FLAGS = {},
	alignment : UINT64 = 0,
) -> RESOURCE_DESC {
	return RESOURCE_DESC {
		Dimension = .BUFFER,
        Alignment = UINT64(alignment),
        Width = UINT64(width),
        Height = 1,
        DepthOrArraySize = 1,
        MipLevels = 1,
        Format = .UNKNOWN,
        SampleDesc = {Count = 1, Quality = 0},
        Layout = .ROW_MAJOR,
        Flags = {},
	}
}
