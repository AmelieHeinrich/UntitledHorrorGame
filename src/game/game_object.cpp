/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 20:24:14
 */

#include "game_object.hpp"

#include <core/logger.hpp>

void GameObject::InitRender(const std::string& modelPath)
{
    HasRenderable = true;
    Renderable.ModelPath = modelPath;
    
    CPUModel model;
    model.Load(modelPath);

    for (auto mesh : model.Meshes) {
        GpuMesh gpu_mesh = {};
        gpu_mesh.VertexBuffer = Buffer::CreateFromData(mesh.Vertices.data(), mesh.Vertices.size() * sizeof(Vertex), sizeof(Vertex), BufferType::Vertex);
        gpu_mesh.IndexBuffer = Buffer::CreateFromData(mesh.Indices.data(), mesh.Indices.size() * sizeof(u32), sizeof(u32), BufferType::Index);
        gpu_mesh.VertexCount = mesh.Vertices.size();
        gpu_mesh.IndexCount = mesh.Indices.size();

        Renderable.Meshes.push_back(gpu_mesh);
    }
}

void GameObject::InitRender(const CPUModel& model, const std::string& path)
{
    HasRenderable = true;
    Renderable.ModelPath = path;

    for (auto mesh : model.Meshes) {
        GpuMesh gpu_mesh = {};
        gpu_mesh.VertexBuffer = Buffer::CreateFromData(mesh.Vertices.data(), mesh.Vertices.size() * sizeof(Vertex), sizeof(Vertex), BufferType::Vertex);
        gpu_mesh.IndexBuffer = Buffer::CreateFromData(mesh.Indices.data(), mesh.Indices.size() * sizeof(u32), sizeof(u32), BufferType::Index);
        gpu_mesh.VertexCount = mesh.Vertices.size();
        gpu_mesh.IndexCount = mesh.Indices.size();

        Renderable.Meshes.push_back(gpu_mesh);
    }
}

void GameObject::FreeRender()
{
    if (!HasRenderable) {
        LOG_WARN("Trying to free a render component on an object that doesn't have one!");
        return;
    }

    Renderable.Meshes.clear();
    Renderable.Textures.clear();

    HasRenderable = false;
}

void GameObject::InitTexture(EntityTextureType type, const std::string& path)
{
    if (!HasRenderable) {
        LOG_WARN("Trying to init a texture on an object that doesn't have a render component!");
        return;
    }

    Image image;
    image.LoadFromFile(path);

    Renderable.Textures[type].Valid = true;
    Renderable.Textures[type].Path = path;
    Renderable.Textures[type].Texture = Texture::CreateFromImage(image);
}

void GameObject::InitTexture(EntityTextureType type, const Image& image, const std::string& path)
{
    if (!HasRenderable) {
        LOG_WARN("Trying to init a texture on an object that doesn't have a render component!");
        return;
    }

    Renderable.Textures[type].Valid = true;
    Renderable.Textures[type].Path = path;
    Renderable.Textures[type].Texture = Texture::CreateFromImage(image);
}

void GameObject::FreeTexture(EntityTextureType type)
{
    if (!HasRenderable) {
        LOG_WARN("Trying to free a texture on an object that doesn't have a render component!");
        return;
    }

    Renderable.Textures.clear();
}
