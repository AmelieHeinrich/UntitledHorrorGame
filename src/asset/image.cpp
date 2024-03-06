/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:12:28
 */

#include "image.hpp"

#include <core/logger.hpp>

Image::~Image()
{
    Destroy();
}

void Image::Destroy()
{
    if (Bytes != nullptr) {
        delete[] Bytes;
        Bytes = nullptr;
    }
}

void Image::LoadFromFile(const std::string& path, bool flip)
{
    int channels;

    stbi_set_flip_vertically_on_load(flip);
    Bytes = stbi_load(path.c_str(), &Width, &Height, &channels, STBI_rgb_alpha);
    if (!Bytes) {
        LOG_ERROR("Failed to load image {0}", path.c_str());
    }
}

void Image::LoadHDR(const std::string& path)
{
    int channels;

    stbi_set_flip_vertically_on_load(false);
    Bytes = reinterpret_cast<u8*>(stbi_loadf(path.c_str(), &Width, &Height, &channels, STBI_rgb_alpha));
    if (!Bytes) {
        LOG_ERROR("Failed to load image {0}", path.c_str());
    }
}
