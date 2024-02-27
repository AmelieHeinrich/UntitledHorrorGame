/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 19:03:52
 */

#include "memory_tracker.hpp"

std::unordered_map<MemoryDomain, u64> MemoryTracker::_UsedMemory;

void MemoryTracker::Init()
{
    _UsedMemory[MemoryDomain::ASSETS] = 0;
    _UsedMemory[MemoryDomain::SCENE] = 0;
    _UsedMemory[MemoryDomain::TEXTURES] = 0;
    _UsedMemory[MemoryDomain::BUFFERS] = 0;
}

void MemoryTracker::Push(MemoryDomain domain, u64 size)
{
    _UsedMemory[domain] += size;
}

void MemoryTracker::Pop(MemoryDomain domain, u64 size)
{
    _UsedMemory[domain] -= size;
}
