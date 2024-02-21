/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 22:47:24
 */

#include "sampler.hpp"
#include "context.hpp"

#include <core/logger.hpp>

Sampler::Sampler(Address address, Filter filter, i32 anisotropyLevel)
    : _Address(address), _Filter(filter), _AnisotropyLevel(anisotropyLevel)
{
    D3D11_SAMPLER_DESC desc = {};
    desc.Filter = D3D11_FILTER(filter);
    desc.AddressU = D3D11_TEXTURE_ADDRESS_MODE(address);
    desc.AddressV = desc.AddressU;
    desc.AddressW = desc.AddressU;
    desc.MipLODBias = 0.0f;
    desc.MaxAnisotropy = anisotropyLevel;
    desc.ComparisonFunc = D3D11_COMPARISON_NEVER;
    desc.MinLOD = 0;
    desc.MaxLOD = D3D11_FLOAT32_MAX;

    HRESULT result = RenderContext::Device()->CreateSamplerState(&desc, &_Sampler);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create sampler!");
    }
}

Sampler::~Sampler()
{
    SafeRelease(_Sampler);
}
