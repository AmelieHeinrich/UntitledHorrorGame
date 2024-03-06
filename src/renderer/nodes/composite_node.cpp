/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 18:06:58
 */

#include "composite_node.hpp"

#include <game.hpp>

#include <rhi/context.hpp>

CompositeNode::CompositeNode(Ref<Texture> colorTexture)
    : _input(colorTexture)
{
    _output = CreateRef<Texture>(TextureType::TwoDimension, TextureLayout::RenderNode, state.width, state.height, DXGI_FORMAT_R8G8B8A8_UNORM);
    _output->MakeRenderTarget();
    _output->MakeUnorderedAccess();

    _compositePipeline = CreateRef<ComputePipeline>(ShaderCompiler::CompileFromFile("gamedata/shaders/Composite/Composite_Cpt.hlsl", "cs_5_0"));
}

void CompositeNode::Render(Ref<Scene> scene)
{
    RenderContext::BindComputePipeline(_compositePipeline);
    RenderContext::BindComputeShaderResource(_input, 0);
    RenderContext::BindComputeUnorderedViewTexture(_output, 1);

    RenderContext::Dispatch(state.width / 31, state.height / 31, 1);

    RenderContext::UnbindComputeShaderResource(0);
    RenderContext::UnbindComputeUnorderedViewTexture(1);
}
