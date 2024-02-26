/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 20:19:09
 */

#pragma once

#include <asset/image.hpp>
#include <asset/model.hpp>

#include <renderer/buffer.hpp>
#include <renderer/texture.hpp>

#include <glm/glm.hpp>

#include <string>
#include <vector>
#include <unordered_map>

enum class EntityTextureType
{
    Albedo,
    Normal,
    Metallic,
    Roughness,
    MetallicRoughness
};

struct GpuMesh
{
    Ref<Buffer> VertexBuffer;
    Ref<Buffer> IndexBuffer;

    u32 VertexCount;
    u32 IndexCount;
};

struct TextureInfo
{
    bool Valid = false;
    std::string Path = "";
    Ref<Texture> Texture;
};

struct RenderableComponent
{
    std::string ModelPath;
    std::vector<GpuMesh> Meshes;

    std::unordered_map<EntityTextureType, TextureInfo> Textures;
};

struct GameObject
{
public:
    std::string Name = "Entity";

    glm::vec3 Position = glm::vec3(0.0f);
    glm::vec3 Rotation = glm::vec3(0.0f);
    glm::vec3 Scale = glm::vec3(1.0f);
    glm::mat4 Transform = glm::mat4(1.0f);

    bool HasRenderable = false;
    RenderableComponent Renderable;
public:
    void InitRender(const std::string& modelPath);
    void InitRender(const CPUModel& image, const std::string& path);
    void FreeRender();
    void InitTexture(EntityTextureType type, const std::string& path);
    void InitTexture(EntityTextureType type, const Image& image, const std::string& path);
    void FreeTexture(EntityTextureType type);

private:
    friend class Scene;
    i32 ArrayIndex;
};
