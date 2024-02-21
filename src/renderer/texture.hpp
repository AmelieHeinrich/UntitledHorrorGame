/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 19:02:35
 */

#pragma once

#include <d3d11.h>
#include <cstddef>

#include <core/core.hpp>
#include <asset/image.hpp>

enum class TextureType
{
    TwoDimension = 1,
    CubeMap = 6
};

enum class TextureLayout
{
    RenderTarget = D3D11_BIND_RENDER_TARGET,
    DepthStencil = D3D11_BIND_DEPTH_STENCIL,
    ShaderResource = D3D11_BIND_SHADER_RESOURCE,
    UnorderedAccess = D3D11_BIND_UNORDERED_ACCESS,
    Staging = 0
};

class Texture
{
public:
    Texture() = default;
    Texture(TextureType type, TextureLayout layout, int width, int height, DXGI_FORMAT format);
    ~Texture();

    void Upload(const void *data, i64 size);

    void MakeRenderTarget();
    void MakeDepthStencil();
    void MakeShaderResource();
    void MakeUnorederedAccess();

    static Ref<Texture> CreateFromImage(const Image& image);
private:
    friend class SwapChain;
    friend class RenderContext;

    TextureType _Type;
    ID3D11Texture2D* _Texture = nullptr;

    DXGI_FORMAT _Format;
    int _Width;
    int _Height;

    ID3D11RenderTargetView* _RTV = nullptr;
    ID3D11DepthStencilView* _DSV = nullptr;
    ID3D11ShaderResourceView* _SRV = nullptr;
    ID3D11UnorderedAccessView* _UAV = nullptr;
};
