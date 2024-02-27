/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:01:53
 */

#pragma once

#include <rhi/graphics_pipeline.hpp>
#include <rhi/buffer.hpp>
#include <rhi/texture.hpp>
#include <rhi/sampler.hpp>

#include <renderer/render_node.hpp>

class ForwardNode : public IRenderNode
{
public:
    ForwardNode();
    ~ForwardNode() = default;

    virtual void Render(Ref<Scene> scene) override;
    virtual Ref<Texture> GetFinalOutput() override { return _ForwardTarget; }
    virtual std::string GetName() const override { return "Forward Pass"; }
private:
    Ref<Texture> _ErrorTexture;
    Ref<GraphicsPipeline> _Forward;
    Ref<Texture> _ForwardTarget;
    Ref<Texture> _ForwardDepth;
    Ref<Sampler> _ForwardSampler;
    Ref<Buffer> _CameraBuffer;
    Ref<Buffer> _ModelBuffer;
};
