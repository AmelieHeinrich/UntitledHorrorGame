/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:19:55
 */

#pragma once

#include <rhi/compute_pipeline.hpp>

#include <renderer/render_node.hpp>

class FXAANode : public IRenderNode
{
public:
    FXAANode(Ref<Texture> colorTexture);

    virtual void Render(Ref<Scene> scene) override;
    virtual Ref<Texture> GetFinalOutput() override { return _outputTexture; }
    virtual std::string GetName() const override { return "FXAA Pass"; }
private:
    Ref<ComputePipeline> _fxaaPipeline;
    Ref<Texture> _outputTexture;
};
