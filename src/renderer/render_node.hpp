/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 16:59:18
 */

#pragma once

#include <vector>

#include <rhi/texture.hpp>

#include <game/scene.hpp>

class IRenderNode
{
public:
    IRenderNode() = default;
    ~IRenderNode() = default;

    virtual void Render(Ref<Scene> scene) = 0;

    virtual Ref<Texture> GetFinalOutput() { return nullptr; };
    virtual std::string GetName() const = 0;

    virtual void Enable(bool enable) { _Enabled = enable; };
    virtual bool Enabled() const { return _Enabled; }
private:
    bool _Enabled = true;
};
