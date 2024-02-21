/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 21:04:40
 */

#pragma once

#include <renderer/graphics_pipeline.hpp>
#include <renderer/buffer.hpp>
#include <renderer/texture.hpp>
#include <renderer/sampler.hpp>

#include "scene.hpp"

class SceneRenderer
{
public:
    SceneRenderer();
    ~SceneRenderer() = default;

    void Render(Ref<Scene> scene);
    
    // Will be updated as the renderer progresses
    Ref<Texture> CompositionTexture() { return _ForwardTarget; }
private:
    Ref<Texture> _ErrorTexture;
    Ref<GraphicsPipeline> _Forward;
    Ref<Texture> _ForwardTarget;
    Ref<Texture> _ForwardDepth;
    Ref<Sampler> _ForwardSampler;
    Ref<Buffer> _CameraBuffer;
    Ref<Buffer> _ModelBuffer;
};
