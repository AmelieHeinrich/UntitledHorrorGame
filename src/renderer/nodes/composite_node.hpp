/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 18:05:35
 */

#pragma once

#include <rhi/compute_pipeline.hpp>

#include <renderer/render_node.hpp>

class CompositeNode : public IRenderNode
{
public:
    CompositeNode(Ref<Texture> colorTexture);

    virtual void Render(Ref<Scene> scene) override;
    virtual Ref<Texture> GetFinalOutput() override { return _output; }
    virtual std::string GetName() const override { return "Composite Pass"; }
private:
    Ref<ComputePipeline> _compositePipeline;
    Ref<Texture> _input;
    Ref<Texture> _output;
};
