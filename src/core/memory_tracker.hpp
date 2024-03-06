/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 19:00:17
 */

#pragma once

#include "core.hpp"

#include <unordered_map>
#include <vector>

#define BYTES_TO_KILOBYTES(bytes) (bytes / 1024.0f)
#define BYTES_TO_MEGABYTES(bytes) BYTES_TO_KILOBYTES(bytes) / 1024.0f
#define BYTES_TO_GIGABYTES(bytes) BYTES_TO_MEGABYTES(bytes) / 1024.0f

enum class MemoryDomain
{
    ASSETS,
    SCENE,
    TEXTURES,
    BUFFERS
};

class MemoryTracker
{
public:
    static void Init();
    static void Push(MemoryDomain domain, u64 size);
    static void Pop(MemoryDomain domain, u64 size);

    static u64 GetUsedMemory(MemoryDomain domain) { return _UsedMemory[domain]; }
private:
    static std::unordered_map<MemoryDomain, u64> _UsedMemory;
};
