/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 14:33:15
 */

#pragma once

#include <core/core.hpp>
#include <core/window.hpp>

#include <d3d11.h>
#include <dxgi1_6.h>
#include <memory>

#include "swap_chain.hpp"
#include "buffer.hpp"
#include "texture.hpp"
#include "graphics_pipeline.hpp"
#include "sampler.hpp"

#define SafeRelease(ptr) if (ptr) { ptr->Release(); }

class RenderContext
{
public:
    static void Init();
    static void InitImGui();
    static void ExitImGui();
    static void Exit();

    static void SetViewport(i32 width, i32 height);
    static void BindRenderTarget(Ref<Texture> color, Ref<Texture> depth = nullptr);
    static void ClearRenderTarget(Ref<Texture> texture, f32 r, f32 g, f32 b, f32 a);
    static void ClearDepthTarget(Ref<Texture> texture, f32 depth, f32 stencil);

    static void CopyBufferToBuffer(Ref<Buffer> dst, Ref<Buffer> src);
    static void CopyBufferToTexture(Ref<Texture> dst, Ref<Buffer> src);
    static void CopyTextureToBuffer(Ref<Buffer> dst, Ref<Texture> src);
    static void CopyTextureToTexture(Ref<Texture> dst, Ref<Texture> src);

    static void BindGraphicsPipeline(Ref<GraphicsPipeline> pipeline);
    static void BindGraphicsVertexConstantBuffer(Ref<Buffer> buffer, i32 slot);
    static void BindGraphicsPixelConstantBuffer(Ref<Buffer> buffer, i32 slot);
    static void BindGraphicsShaderResource(Ref<Texture> texture, i32 slot);
    static void BindGraphicsSampler(Ref<Sampler> sampler, i32 slot);
    static void BindBuffer(Ref<Buffer> buffer);

    static void Draw(u32 count);
    static void DrawIndexed(u32 count);

    static void Present(bool vsync);

    static void BeginUI();
    static void EndUI();

    static void AttachWindow(Ref<Window> window);
    static void Resize(int width, int height);

    static Ref<Texture> GetBackBuffer() { return _Data._SwapChain->PullBackBuffer(); }

    static ID3D11Device* Device() { return _Data._Device; }
    static ID3D11DeviceContext* Context() { return _Data._DeviceContext; }
    static IDXGIFactory* Factory() { return _Data._Factory; }
private:
    struct Data
    {
        IDXGIAdapter* _Adapter;
        IDXGIFactory* _Factory;
        IDXGIDevice* _DXGIDevice;
        ID3D11Device* _Device;
        ID3D11DeviceContext* _DeviceContext;

        Ref<Window> _Window;
        Ref<SwapChain> _SwapChain;
    };

    static Data _Data;
};
