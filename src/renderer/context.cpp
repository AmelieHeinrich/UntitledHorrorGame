/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 18:46:02
 */

#include "context.hpp"
#include "game.hpp"

#include <core/logger.hpp>

#include <imgui/imgui.h>
#include <imgui/imgui_impl_dx11.h>
#include <imgui/imgui_impl_glfw.h>
#include <imguizmo/ImGuizmo.h>

extern "C" 
{
    __declspec(dllexport) DWORD NvOptimusEnablement = 0x00000001;
    __declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
}

const D3D_DRIVER_TYPE driver_types[] =
{
    D3D_DRIVER_TYPE_HARDWARE,
    D3D_DRIVER_TYPE_WARP,
    D3D_DRIVER_TYPE_REFERENCE,
};

RenderContext::Data RenderContext::_Data;

void RenderContext::Init()
{
    D3D_FEATURE_LEVEL targetLevel;
    D3D_FEATURE_LEVEL levels[] = {D3D_FEATURE_LEVEL_11_0};
    HRESULT result = 0;
    for (int i = 0; i < ARRAYSIZE(driver_types); i++) {
        result = D3D11CreateDevice(NULL, driver_types[i], NULL, D3D11_CREATE_DEVICE_DEBUG, levels, 1, D3D11_SDK_VERSION, &_Data._Device, &targetLevel, &_Data._DeviceContext);
        if (SUCCEEDED(result))
            break;
    }

    if (FAILED(result))
        LOG_CRITICAL("Failed to create D3D11 device!");
    
    _Data._Device->QueryInterface(IID_PPV_ARGS(&_Data._DXGIDevice));
    _Data._DXGIDevice->GetParent(IID_PPV_ARGS(&_Data._Adapter));
    _Data._Adapter->GetParent(IID_PPV_ARGS(&_Data._Factory));
}

void RenderContext::InitImGui()
{
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    
    ImGui::StyleColorsDark();

    ImGui_ImplGlfw_InitForOther(_Data._Window->GetGLFWWindow(), true);
    ImGui_ImplDX11_Init(_Data._Device, _Data._DeviceContext);
}

void RenderContext::ExitImGui()
{
    ImGui_ImplDX11_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
}

void RenderContext::BeginUI()
{
    ImGui_ImplDX11_NewFrame();
    ImGui_ImplGlfw_NewFrame();
	ImGui::NewFrame();
    ImGuizmo::BeginFrame();
}

void RenderContext::EndUI()
{
    ImGuiIO& io = ImGui::GetIO();
	io.DisplaySize = ImVec2(state.width, state.height);

	// Rendering
	ImGui::Render();
	ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
}

void RenderContext::Exit()
{
    _Data._Factory->Release();
    _Data._Adapter->Release();
    _Data._DXGIDevice->Release();
    _Data._Device->Release();
}

void RenderContext::SetViewport(i32 width, i32 height)
{
    D3D11_VIEWPORT viewport = {};
    viewport.TopLeftX = 0;
    viewport.TopLeftY = 0;
    viewport.Width = (FLOAT)width;
    viewport.Height = (FLOAT)height;
    viewport.MinDepth = 0.0f;
    viewport.MaxDepth = 1.0f;

    _Data._DeviceContext->RSSetViewports(1, &viewport);
}

void RenderContext::BindRenderTarget(Ref<Texture> color, Ref<Texture> depth)
{
    ID3D11RenderTargetView* rtv = color->_RTV;
    ID3D11DepthStencilView* dsv = depth ? depth->_DSV : nullptr;

    _Data._DeviceContext->OMSetRenderTargets(1, &rtv, dsv);
}

void RenderContext::ClearRenderTarget(Ref<Texture> texture, f32 r, f32 g, f32 b, f32 a)
{
    f32 color[4] = { r, g, b, a };
    _Data._DeviceContext->ClearRenderTargetView(texture->_RTV, color);
}

void RenderContext::ClearDepthTarget(Ref<Texture> texture, f32 depth, f32 stencil)
{
    _Data._DeviceContext->ClearDepthStencilView(texture->_DSV, D3D11_CLEAR_DEPTH, depth, stencil);
}

void RenderContext::CopyBufferToBuffer(Ref<Buffer> dst, Ref<Buffer> src)
{
    _Data._DeviceContext->CopyResource(dst->_Buffer, src->_Buffer);
}

void RenderContext::CopyBufferToTexture(Ref<Texture> dst, Ref<Buffer> src)
{
    _Data._DeviceContext->CopyResource(dst->_Texture, src->_Buffer);
}

void RenderContext::CopyTextureToBuffer(Ref<Buffer> dst, Ref<Texture> src)
{
    _Data._DeviceContext->CopyResource(dst->_Buffer, src->_Texture);
}

void RenderContext::CopyTextureToTexture(Ref<Texture> dst, Ref<Texture> src)
{
    _Data._DeviceContext->CopyResource(dst->_Texture, src->_Texture);
}

void RenderContext::BindGraphicsPipeline(Ref<GraphicsPipeline> pipeline)
{
    _Data._DeviceContext->VSSetShader(pipeline->_VertexShader, nullptr, 0);
    _Data._DeviceContext->PSSetShader(pipeline->_PixelShader, nullptr, 0);
    _Data._DeviceContext->IASetInputLayout(pipeline->_Layout);
    _Data._DeviceContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
}

void RenderContext::BindGraphicsVertexConstantBuffer(Ref<Buffer> buffer, i32 slot)
{
    _Data._DeviceContext->VSSetConstantBuffers(slot, 1, &buffer->_Buffer);
}

void RenderContext::BindGraphicsPixelConstantBuffer(Ref<Buffer> buffer, i32 slot)
{
    _Data._DeviceContext->PSSetConstantBuffers(slot, 1, &buffer->_Buffer);
}

void RenderContext::BindGraphicsShaderResource(Ref<Texture> texture, i32 slot)
{
    _Data._DeviceContext->PSSetShaderResources(slot, 1, &texture->_SRV);
}

void RenderContext::BindGraphicsSampler(Ref<Sampler> sampler, i32 slot)
{
    _Data._DeviceContext->PSSetSamplers(slot, 1, &sampler->_Sampler);
}

void RenderContext::BindBuffer(Ref<Buffer> buffer)
{
    switch (buffer->_Type) {
        case BufferType::Vertex: {
            UINT stride[] = { u32(buffer->_Stride) };
            UINT offset[] = { 0 };
            _Data._DeviceContext->IASetVertexBuffers(0, 1, &buffer->_Buffer, stride, offset);
            break;
        }
        case BufferType::Index: {
            _Data._DeviceContext->IASetIndexBuffer(buffer->_Buffer, DXGI_FORMAT_R32_UINT, 0);
            break;
        }
    }
}

void RenderContext::Draw(u32 count)
{
    _Data._DeviceContext->Draw(count, 0);
}

void RenderContext::DrawIndexed(u32 count)
{
    _Data._DeviceContext->DrawIndexed(count, 0, 0);
}

void RenderContext::AttachWindow(Ref<Window> window)
{
    _Data._Window = window;
    _Data._SwapChain = CreateRef<SwapChain>(_Data._Window);
}

void RenderContext::Resize(int width, int height)
{
    _Data._SwapChain->Resize(width, height);
}

void RenderContext::Present(bool vsync)
{
    _Data._SwapChain->Present(vsync);
}
