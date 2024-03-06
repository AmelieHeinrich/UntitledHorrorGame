/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 13:34:24
 */

#pragma once

#include <core/core.hpp>
#include <d3d11.h>

enum class BufferType
{
    Vertex = D3D11_BIND_VERTEX_BUFFER,
    Index = D3D11_BIND_INDEX_BUFFER,
    Constant = D3D11_BIND_CONSTANT_BUFFER,
    Staging = 0
};

class Buffer
{
public:
    Buffer(i64 size, i64 stride, BufferType type);
    ~Buffer();

    void Upload(const void *data, i64 size);

    void MakeUnorderedAccess();

    static Ref<Buffer> CreateFromData(const void* data, i64 size, i64 stride, BufferType type);
private:
    friend class RenderContext;

    ID3D11Buffer* _Buffer = nullptr;
    ID3D11UnorderedAccessView* _UAV = nullptr;
    i64 _Size;
    i64 _Stride;
    BufferType _Type;
};
