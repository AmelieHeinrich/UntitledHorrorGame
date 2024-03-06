/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 10:03:36
 */

#pragma once

#include <core/window.hpp>
#include <core/core.hpp>

#include "texture.hpp"

class SwapChain
{
public:
    SwapChain(Ref<Window> window);
    ~SwapChain();

    void Resize(i32 width, i32 height);
    void Present(bool vsync);

    Ref<Texture> PullBackBuffer();
private:
    Ref<Window> _TargetWindow;
    Ref<Texture> _BackBufferWrap;

    IDXGISwapChain* _SwapChain = nullptr;
    ID3D11Texture2D* _BackBuffer = nullptr;
    ID3D11RenderTargetView* _RenderTarget = nullptr;
};
