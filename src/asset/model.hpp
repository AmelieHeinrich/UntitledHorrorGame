/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 18:24:50
 */

#pragma once

#include <vector>
#include <string>

#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/pbrmaterial.h>

#include <core/core.hpp>

struct Vertex
{
    glm::vec3 Position;
    glm::vec3 Normals;
    glm::vec2 UVs;
};

struct MeshData
{
    std::vector<Vertex> Vertices;
    std::vector<u32> Indices;

    glm::vec3 Translation;
    glm::vec3 Scale;
    glm::quat Rotation;
    glm::mat4 Transform;
};

class CPUModel
{
public:
    ~CPUModel();

    std::vector<MeshData> Meshes;
    std::string Path;

    void Load(const std::string& path);
    void Destroy();
private:
    void ProcessNode(aiNode *node, const aiScene* scene);
    MeshData ProcessMesh(aiMesh *mesh, const aiScene *scene);
};
