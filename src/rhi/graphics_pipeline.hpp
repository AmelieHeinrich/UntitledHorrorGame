/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 14:19:07
 */

#pragma once

#include <core/core.hpp>
#include <d3d11.h>

#include "shader.hpp"

enum class PolygonFill
{
    Fill = D3D11_FILL_SOLID,
    Line = D3D11_FILL_WIREFRAME
};

enum class Cull
{
    None = D3D11_CULL_NONE,
    Front = D3D11_CULL_FRONT,
    Back = D3D11_CULL_BACK
};

enum class Comparison
{
    Never = D3D11_COMPARISON_NEVER,
    Less = D3D11_COMPARISON_LESS,
    Equal = D3D11_COMPARISON_EQUAL,
    LessEqual = D3D11_COMPARISON_LESS_EQUAL,
    Greater = D3D11_COMPARISON_GREATER,
    NotEqual = D3D11_COMPARISON_NOT_EQUAL,
    GreaterEqual = D3D11_COMPARISON_GREATER_EQUAL,
    Always = D3D11_COMPARISON_ALWAYS
};

struct GraphicsPipelineCreateInfo
{
    ShaderBytecode vertexShader;
    ShaderBytecode pixelShader;
    PolygonFill fill;
    Cull cull;
    Comparison depth;
    bool ccwWinding;
};

class GraphicsPipeline
{
public:
    GraphicsPipeline(const GraphicsPipelineCreateInfo& createInfo);
    ~GraphicsPipeline();

private:
    friend class RenderContext;

    ID3D11VertexShader* _VertexShader;
    ID3D11PixelShader* _PixelShader;
    ID3D11InputLayout* _Layout;
    ID3D11RasterizerState* _RasterizerState;
    ID3D11DepthStencilState* _DepthStencilState;
};
