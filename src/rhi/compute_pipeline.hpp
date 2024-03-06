/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 22:40:57
 */

#pragma once

#include "shader.hpp"

#include <d3d11.h>

class ComputePipeline
{
public:
    ComputePipeline(const ShaderBytecode& computeBytecode);
    ~ComputePipeline();

private:
    friend class RenderContext;

    ID3D11ComputeShader *_Shader;
};
