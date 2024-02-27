/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 19:10:42
 */

#include "texture.hpp"
#include "context.hpp"

#include <core/logger.hpp>

Texture::Texture(TextureType type, TextureLayout layout, int width, int height, DXGI_FORMAT format, bool mips)
    : _Width(width), _Height(height), _Type(type), _Format(format), _Mips(mips)
{
    D3D11_TEXTURE2D_DESC desc {};
    desc.Width = width;
    desc.Height = height;
    desc.Format = format;
    desc.ArraySize = int(type);
    desc.BindFlags = D3D11_BIND_FLAG(layout);
    desc.Usage = D3D11_USAGE_DEFAULT;
    desc.SampleDesc.Count = 1;
    desc.MipLevels = 1;
    if (type == TextureType::CubeMap)
        desc.MiscFlags = D3D11_RESOURCE_MISC_TEXTURECUBE;
    if (layout == TextureLayout::Staging) {
        desc.BindFlags = 0;
        desc.Usage = D3D11_USAGE_STAGING;
        desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE | D3D11_CPU_ACCESS_READ;
    }
    if (_Mips) {
        desc.MipLevels = 0;
        desc.MiscFlags = D3D11_RESOURCE_MISC_GENERATE_MIPS;
    }

    HRESULT result = RenderContext::Device()->CreateTexture2D(&desc, nullptr, &_Texture);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create Texture2D!");
    }
}

Texture::~Texture()
{
    SafeRelease(_Texture);
}

void Texture::Upload(const void *data, i64 size)
{
    D3D11_MAPPED_SUBRESOURCE subresource = {};

    RenderContext::Context()->Map(_Texture, 0, D3D11_MAP_WRITE, 0, &subresource);
    memcpy(subresource.pData, data, size);
    RenderContext::Context()->Unmap(_Texture, 0);
}

void Texture::MakeRenderTarget()
{
    HRESULT result = RenderContext::Device()->CreateRenderTargetView(_Texture, nullptr, &_RTV);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create Render Target!");
    }
}

void Texture::MakeDepthStencil()
{
    HRESULT result = RenderContext::Device()->CreateDepthStencilView(_Texture, nullptr, &_DSV);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create Depth Stencil!");
    }
}

void Texture::MakeShaderResource()
{
    D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = {};
    srvDesc.Format = _Format;
    if (_Type == TextureType::CubeMap) {
        srvDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURECUBE;
        srvDesc.TextureCube.MostDetailedMip = 0;
        srvDesc.TextureCube.MipLevels = 1;
    } else {
        srvDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
        srvDesc.Texture2D.MostDetailedMip = 0;
        if (_Mips) {
            srvDesc.Texture2D.MipLevels = -1;
        } else {
            srvDesc.Texture2D.MipLevels = 1;
        }
    }

    HRESULT result = RenderContext::Device()->CreateShaderResourceView(_Texture, &srvDesc, &_SRV);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create shader resource!");
    }

    if (_Mips) {
        RenderContext::Context()->GenerateMips(_SRV);
    }
}

void Texture::MakeUnorderedAccess()
{
    D3D11_UNORDERED_ACCESS_VIEW_DESC uavDesc = {};
    uavDesc.Format = _Format;
    if (_Type == TextureType::CubeMap) {
        uavDesc.ViewDimension = D3D11_UAV_DIMENSION_TEXTURE2DARRAY;
        uavDesc.Texture2DArray.MipSlice = 0;
        uavDesc.Texture2DArray.ArraySize = 6;
    } else {
        uavDesc.ViewDimension = D3D11_UAV_DIMENSION_TEXTURE2D;
        uavDesc.Texture2D.MipSlice = 0;
    }

    HRESULT result = RenderContext::Device()->CreateUnorderedAccessView(_Texture, &uavDesc, &_UAV);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create unordered access view!");
    }
}

Ref<Texture> Texture::CreateFromImage(const Image& image)
{
    Ref<Texture> staging = CreateRef<Texture>(TextureType::TwoDimension, TextureLayout::Staging, image.Width, image.Height, DXGI_FORMAT_R8G8B8A8_UNORM);
    staging->Upload(image.Bytes, image.Width * image.Height * 4);

    Ref<Texture> gpu_resident = CreateRef<Texture>(TextureType::TwoDimension, TextureLayout::MippedTexture, image.Width, image.Height, DXGI_FORMAT_R8G8B8A8_UNORM);
    RenderContext::CopyTextureToTexture(gpu_resident, staging);
    gpu_resident->MakeShaderResource();

    return gpu_resident;
}
