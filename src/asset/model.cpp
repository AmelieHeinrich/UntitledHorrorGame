/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 18:54:01
 */

#include "model.hpp"

#include <core/logger.hpp>

CPUModel::~CPUModel()
{
    Destroy();
}

void CPUModel::Load(const std::string& path)
{
    Assimp::Importer importer;
    const aiScene* scene = importer.ReadFile(path, aiProcess_FlipWindingOrder);
    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
        LOG_ERROR("Failed to load model file {0}: {1}", path.c_str(), importer.GetErrorString());
    }
    ProcessNode(scene->mRootNode, scene);
}

void CPUModel::Destroy()
{
    if (Meshes.size() == 0)
        return;

    for (auto mesh : Meshes) {
        mesh.Vertices.clear();
        mesh.Indices.clear();
    }
    Meshes.clear();
}

void CPUModel::ProcessNode(aiNode *node, const aiScene* scene)
{
    for (u32 i = 0; i < node->mNumMeshes; i++) {
        Meshes.push_back(ProcessMesh(scene->mMeshes[node->mMeshes[i]], scene));
    }
    for (u32 i = 0; i < node->mNumChildren; i++) {
        ProcessNode(node->mChildren[i], scene);
    }
}

MeshData CPUModel::ProcessMesh(aiMesh *mesh, const aiScene *scene)
{
    MeshData out;

    out.AABB.Min = glm::vec3(FLT_MAX);
    out.AABB.Max = glm::vec3(FLT_MIN);

    for (u32 i = 0; i < mesh->mNumVertices; i++) {
        Vertex vertex;
        vertex.Position.x = mesh->mVertices[i].x;
        vertex.Position.y = mesh->mVertices[i].y;
        vertex.Position.z = mesh->mVertices[i].z;

        out.AABB.Min = glm::min(vertex.Position, out.AABB.Min);
        out.AABB.Max = glm::max(vertex.Position, out.AABB.Max);

        if (mesh->HasNormals())
        {
            vertex.Normals.x = mesh->mNormals[i].x;
            vertex.Normals.y = mesh->mNormals[i].y;
            vertex.Normals.z = mesh->mNormals[i].z;
        }
        
        if (mesh->mTextureCoords[0])
        {
            vertex.UVs.x = mesh->mTextureCoords[0][i].x;
            vertex.UVs.y = mesh->mTextureCoords[0][i].y;
        }
        else
            vertex.UVs = glm::vec2(0.0f);
        
        out.Vertices.push_back(vertex);
    }
    
    for (u32 i = 0; i < mesh->mNumFaces; i++) {
        aiFace face = mesh->mFaces[i];
        for (u32 j = 0; j < face.mNumIndices; j++) {
            out.Indices.push_back(face.mIndices[j]);
        }
    }

    return out;
}