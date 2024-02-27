/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:08:57
 */

#include "render_graph.hpp"

#include <core/logger.hpp>
#include <rhi/context.hpp>

void RenderGraph::PushNode(Ref<IRenderNode> node)
{
    LOG_INFO("RENDER GRAPH: Pushed node {0}.", node->GetName().c_str());
    _Nodes.push_back(node);
}

void RenderGraph::Render(Ref<Scene> scene)
{
    for (Ref<IRenderNode> node : _Nodes) {
        if (node->Enabled())
            node->Render(scene);
    }

    Ref<Texture> swapChainTexture = RenderContext::GetBackBuffer();
    Ref<Texture> compositionTexture = _Nodes.back()->GetFinalOutput();
    RenderContext::CopyTextureToTexture(swapChainTexture, compositionTexture);
}

Ref<IRenderNode> RenderGraph::GetNode(const std::string& name)
{
    for (Ref<IRenderNode> node : _Nodes) {
        if (node->GetName() == name) {
            return node;
        }
    }
}
