/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 22:42:27
 */

#include "compute_pipeline.hpp"
#include "context.hpp"

#include <core/logger.hpp>

ComputePipeline::ComputePipeline(const ShaderBytecode& computeBytecode)
{
    HRESULT result = RenderContext::Device()->CreateComputeShader(computeBytecode.bytecode.data(),
                                                                  computeBytecode.bytecode.size() * sizeof(u32),
                                                                  nullptr,
                                                                  &_Shader);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create compute shader!");
    }
}

ComputePipeline::~ComputePipeline()
{
    SafeRelease(_Shader);
}
