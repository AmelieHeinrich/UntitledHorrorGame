/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:34:51
 */

#include "fxaa_node.hpp"

#include <game.hpp>

#include <rhi/context.hpp>

FXAANode::FXAANode(Ref<Texture> colorTexture)
    : _outputTexture(colorTexture)
{
    _fxaaPipeline = CreateRef<ComputePipeline>(ShaderCompiler::CompileFromFile("gamedata/shaders/FXAA/FXAA_Cpt.hlsl", "cs_5_0"));
}

void FXAANode::Render(Ref<Scene> scene)
{
    RenderContext::BindComputePipeline(_fxaaPipeline);
    RenderContext::BindComputeUnorderedViewTexture(_outputTexture, 0);

    RenderContext::Dispatch(state.width / 31, state.height / 31, 1);

    RenderContext::UnbindComputeUnorderedViewTexture(0);
}
