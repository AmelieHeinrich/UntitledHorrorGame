/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:08:56
 */

#pragma once

#include <core/core.hpp>
#include <stb/stb_image.h>
#include <string>

struct Image
{
    u8* Bytes = nullptr;
    i32 Width = -1;
    i32 Height = -1;

    ~Image();
    
    void Destroy();
    void LoadFromFile(const std::string& path, bool flip = true);
    void LoadHDR(const std::string& path);
};
