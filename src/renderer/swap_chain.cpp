/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 10:30:37
 */

#include "swap_chain.hpp"
#include "context.hpp"

#include <core/logger.hpp>

SwapChain::SwapChain(Ref<Window> window)
    : _TargetWindow(window)
{
    int width = 0, height = 0;
    window->PollSize(&width, &height);

    _BackBufferWrap = CreateRef<Texture>();

    Resize(width, height);
}

SwapChain::~SwapChain()
{
    SafeRelease(_SwapChain);
}

void SwapChain::Resize(i32 width, i32 height)
{
    HWND Window = reinterpret_cast<HWND>(_TargetWindow->GetNativeWindow());

    if (!_SwapChain) {
        DXGI_SWAP_CHAIN_DESC swapDesc = {};
        swapDesc.BufferDesc.Width = width;
        swapDesc.BufferDesc.Height = height;
        swapDesc.BufferDesc.RefreshRate.Numerator = 120; // TODO(ahi): Get refresh rate
        swapDesc.BufferDesc.RefreshRate.Denominator = 1;
        swapDesc.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
        swapDesc.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED;
        swapDesc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
        swapDesc.SampleDesc.Count = 1;		
        swapDesc.SampleDesc.Quality = 0;	
        swapDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
        swapDesc.BufferCount = 1;
        swapDesc.OutputWindow = Window;
        swapDesc.Flags = 0;
        swapDesc.Windowed = TRUE; // TODO(ahi): Fullscreen

        HRESULT result = RenderContext::Factory()->CreateSwapChain(RenderContext::Device(), &swapDesc, &_SwapChain);
        if (FAILED(result)) {
            LOG_ERROR("Failed to create swap chain!");
        }
    }

    SafeRelease(_BackBuffer);
    SafeRelease(_RenderTarget);

    _SwapChain->ResizeBuffers(1, width, height, DXGI_FORMAT_R8G8B8A8_UNORM, 0);
    _SwapChain->GetBuffer(0, IID_PPV_ARGS(&_BackBuffer));
    RenderContext::Device()->CreateRenderTargetView(_BackBuffer, nullptr, &_RenderTarget);

    _BackBufferWrap->_Texture = _BackBuffer;
    _BackBufferWrap->_RTV = _RenderTarget;
    _BackBufferWrap->_Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    _BackBufferWrap->_Width = width;
    _BackBufferWrap->_Height = height;
}

void SwapChain::Present(bool vsync)
{
    _SwapChain->Present(vsync, 0);
}

Ref<Texture> SwapChain::PullBackBuffer()
{
    return _BackBufferWrap;
}
