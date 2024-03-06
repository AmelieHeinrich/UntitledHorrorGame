/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 15:17:14
 */

#include "graphics_pipeline.hpp"
#include "context.hpp"

#include <core/logger.hpp>

#include <d3d11shader.h>
#include <d3dcompiler.h>

GraphicsPipeline::GraphicsPipeline(const GraphicsPipelineCreateInfo& createInfo)
{
    // Create shaders
    RenderContext::Device()->CreateVertexShader(createInfo.vertexShader.bytecode.data(),
                                                createInfo.vertexShader.bytecode.size() * sizeof(u32),
                                                nullptr,
                                                &_VertexShader);
    RenderContext::Device()->CreatePixelShader(createInfo.pixelShader.bytecode.data(),
                                               createInfo.pixelShader.bytecode.size() * sizeof(u32),
                                               nullptr,
                                               &_PixelShader);

    // Reflect input layout
    ID3D11ShaderReflection* reflect = nullptr;
    HRESULT result = D3DReflect(createInfo.vertexShader.bytecode.data(),
                                createInfo.vertexShader.bytecode.size() * sizeof(u32),
                                IID_PPV_ARGS(&reflect));
    if (FAILED(result)) {
        LOG_ERROR("Failed to reflect vertex shader!");
    }

    D3D11_SHADER_DESC shader = {};
    reflect->GetDesc(&shader);

    std::vector<D3D11_INPUT_ELEMENT_DESC> inputLayoutDesc = {};
    for (i32 i = 0; i < shader.InputParameters; i++) {
        D3D11_SIGNATURE_PARAMETER_DESC parameterDesc = {};
        reflect->GetInputParameterDesc(i, &parameterDesc);

        D3D11_INPUT_ELEMENT_DESC elementDesc = {};
        elementDesc.SemanticName = parameterDesc.SemanticName;
        elementDesc.SemanticIndex = parameterDesc.SemanticIndex;
        elementDesc.InputSlot = 0;
        elementDesc.AlignedByteOffset = D3D11_APPEND_ALIGNED_ELEMENT;
        elementDesc.InputSlotClass = D3D11_INPUT_PER_VERTEX_DATA;
        elementDesc.InstanceDataStepRate = 0;   

        if (parameterDesc.Mask == 1) {
            if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) elementDesc.Format = DXGI_FORMAT_R32_UINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) elementDesc.Format = DXGI_FORMAT_R32_SINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) elementDesc.Format = DXGI_FORMAT_R32_FLOAT;
        } else if ( parameterDesc.Mask <= 3 ) {
            if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) elementDesc.Format = DXGI_FORMAT_R32G32_UINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) elementDesc.Format = DXGI_FORMAT_R32G32_SINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) elementDesc.Format = DXGI_FORMAT_R32G32_FLOAT;
        } else if (parameterDesc.Mask <= 7) {
            if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) elementDesc.Format = DXGI_FORMAT_R32G32B32_UINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) elementDesc.Format = DXGI_FORMAT_R32G32B32_SINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) elementDesc.Format = DXGI_FORMAT_R32G32B32_FLOAT;
        } else if (parameterDesc.Mask <= 15) {
            if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) elementDesc.Format = DXGI_FORMAT_R32G32B32A32_UINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) elementDesc.Format = DXGI_FORMAT_R32G32B32A32_SINT;
            else if (parameterDesc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) elementDesc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
        }

        inputLayoutDesc.push_back(elementDesc);
    }

    result = RenderContext::Device()->CreateInputLayout(&inputLayoutDesc[0],
                                                         inputLayoutDesc.size(),
                                                         createInfo.vertexShader.bytecode.data(),
                                                         createInfo.vertexShader.bytecode.size() * sizeof(u32),
                                                         &_Layout);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create input layout!");
    }

    // Rasterizer state
    D3D11_RASTERIZER_DESC rasterizer = {};
    rasterizer.CullMode = D3D11_CULL_MODE(createInfo.cull);
    rasterizer.FillMode = D3D11_FILL_MODE(createInfo.fill);
    rasterizer.FrontCounterClockwise = createInfo.ccwWinding;

    result = RenderContext::Device()->CreateRasterizerState(&rasterizer, &_RasterizerState);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create rasterizer state!");
    }

    D3D11_DEPTH_STENCIL_DESC depthStencilDesc = {};
    depthStencilDesc.DepthEnable = true;
    depthStencilDesc.DepthFunc = D3D11_COMPARISON_FUNC(createInfo.depth);
    depthStencilDesc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;

    result = RenderContext::Device()->CreateDepthStencilState(&depthStencilDesc, &_DepthStencilState);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create depth stencil state!");
    }
}

GraphicsPipeline::~GraphicsPipeline()
{
    SafeRelease(_DepthStencilState);
    SafeRelease(_RasterizerState);
    SafeRelease(_Layout);
    SafeRelease(_PixelShader);
    SafeRelease(_VertexShader);
}
