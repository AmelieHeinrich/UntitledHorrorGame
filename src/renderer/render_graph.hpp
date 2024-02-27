/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:07:05
 */

#pragma once

#include "render_node.hpp"

class RenderGraph
{
public:
    RenderGraph() = default;
    ~RenderGraph() = default;

    void PushNode(Ref<IRenderNode> node);
    void Render(Ref<Scene> scene);

    Ref<IRenderNode> GetNode(const std::string& name);
private:
    std::vector<Ref<IRenderNode>> _Nodes;
};
