/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 22:45:22
 */

#pragma once

#include <d3d11.h>
#include <core/core.hpp>

enum class Address
{
    Wrap = D3D11_TEXTURE_ADDRESS_WRAP,
    Mirror = D3D11_TEXTURE_ADDRESS_MIRROR,
    Clamp = D3D11_TEXTURE_ADDRESS_CLAMP,
    Border = D3D11_TEXTURE_ADDRESS_BORDER
};

enum class Filter
{
    Nearest = D3D11_FILTER_MIN_MAG_MIP_POINT,
    Linear = D3D11_FILTER_MIN_MAG_MIP_LINEAR,
    Anisotropic = D3D11_FILTER_ANISOTROPIC
};

class Sampler
{
public:
    Sampler(Address address, Filter filter, i32 anisotropyLevel);
    ~Sampler();

private:
    friend class RenderContext;

    Address _Address;
    Filter _Filter;
    i32 _AnisotropyLevel;
    ID3D11SamplerState *_Sampler;
};
