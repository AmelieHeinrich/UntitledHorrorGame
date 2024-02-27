/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 13:40:42
 */

#include "buffer.hpp"
#include "context.hpp"

#include <core/logger.hpp>

Buffer::Buffer(i64 size, i64 stride, BufferType type)
    : _Size(size), _Stride(stride), _Type(type)
{
    D3D11_BUFFER_DESC desc = {};
    desc.BindFlags = D3D11_BIND_FLAG(type);
    desc.ByteWidth = _Size;
    desc.Usage = type != BufferType::Staging ? D3D11_USAGE_DEFAULT : D3D11_USAGE_STAGING;
    desc.CPUAccessFlags = type != BufferType::Staging ? 0 : D3D11_CPU_ACCESS_WRITE;
    desc.MiscFlags = 0;
    if (type == BufferType::Constant) {
        desc.Usage = D3D11_USAGE_DYNAMIC;
        desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    }

    HRESULT result = RenderContext::Device()->CreateBuffer(&desc, nullptr, &_Buffer);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create buffer!");
    }

    MemoryTracker::Push(MemoryDomain::BUFFERS, size);
}

Buffer::~Buffer()
{
    MemoryTracker::Pop(MemoryDomain::BUFFERS, _Size);

    SafeRelease(_UAV);
    SafeRelease(_Buffer);
}

void Buffer::Upload(const void *data, i64 size)
{
    D3D11_MAPPED_SUBRESOURCE subresource = {};

    D3D11_MAP map_type = _Type == BufferType::Constant ? D3D11_MAP_WRITE_DISCARD : D3D11_MAP_WRITE;

    HRESULT result = RenderContext::Context()->Map(_Buffer, 0, map_type, 0, &subresource);
    if (FAILED(result)) {
        LOG_ERROR("Failed to map buffer!");
    }
    memcpy(subresource.pData, data, size);
    RenderContext::Context()->Unmap(_Buffer, 0);
}

void Buffer::MakeUnorderedAccess()
{
    D3D11_UNORDERED_ACCESS_VIEW_DESC desc = {};
    desc.Format = DXGI_FORMAT_UNKNOWN;
    desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
    desc.Buffer.FirstElement = 0;
    desc.Buffer.NumElements = _Size;

    HRESULT result = RenderContext::Device()->CreateUnorderedAccessView(_Buffer, &desc, &_UAV);
    if (FAILED(result)) {
        LOG_ERROR("Failed to create unordered access view!");
    }
}

Ref<Buffer> Buffer::CreateFromData(const void* data, i64 size, i64 stride, BufferType type)
{
    Ref<Buffer> staging = CreateRef<Buffer>(size, stride, BufferType::Staging);
    staging->Upload(data, size);

    Ref<Buffer> gpu_resident = CreateRef<Buffer>(size, stride, type);
    RenderContext::CopyBufferToBuffer(gpu_resident, staging);

    return gpu_resident;
}
