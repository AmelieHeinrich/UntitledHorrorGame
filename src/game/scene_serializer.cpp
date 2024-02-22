/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 21:41:50
 */

#include "scene_serializer.hpp"

#include <unordered_map>
#include <string>

#include <core/file_system.hpp>

#include <imgui/imgui.h>
#include <imguizmo/ImGuizmo.h>

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

Ref<Scene> SceneSerializer::Deserialize(const std::string& path)
{
    std::unordered_map<std::string, CPUModel*> modelCache;
    std::unordered_map<std::string, Image*> imageCache;

    nlohmann::json root = FileSystem::ParseJSON(path);

    Ref<Scene> scene = CreateRef<Scene>();
    scene->_Name = root["sceneName"];
    scene->_Path = path;

    auto entity_array = root["entities"].template get<std::vector<nlohmann::json>>();

    for (auto entity_root : entity_array) {
        GameObject *object = scene->NewObject();
        object->Name = entity_root["name"];

        object->Position.x = entity_root["position"][0].template get<float>();
        object->Position.y = entity_root["position"][1].template get<float>();
        object->Position.z = entity_root["position"][2].template get<float>();

        object->Rotation.x = entity_root["rotation"][0].template get<float>();
        object->Rotation.y = entity_root["rotation"][1].template get<float>();
        object->Rotation.z = entity_root["rotation"][2].template get<float>();

        object->Scale.x = entity_root["scale"][0].template get<float>();
        object->Scale.y = entity_root["scale"][1].template get<float>();
        object->Scale.z = entity_root["scale"][2].template get<float>();

        object->HasRenderable = entity_root["renderable"].template get<bool>();
        if (object->HasRenderable) {
            if (modelCache.count(entity_root["modelPath"])) {
                object->InitRender(*modelCache[entity_root["modelPath"]], entity_root["modelPath"]);
            } else {
                CPUModel* model = new CPUModel;
                model->Load(entity_root["modelPath"]);
                modelCache[entity_root["modelPath"]] = model;

                object->InitRender(*model, entity_root["modelPath"]);
            }

            if (entity_root["albedoPath"].size() > 0) {
                if (imageCache.count(entity_root["albedoPath"])) {
                    object->InitTexture(EntityTextureType::Albedo, *imageCache[entity_root["albedoPath"]], entity_root["albedoPath"]);
                } else {
                    Image* image = new Image;
                    image->LoadFromFile(entity_root["albedoPath"]);
                    imageCache[entity_root["albedoPath"]] = image;

                    object->InitTexture(EntityTextureType::Albedo, *image, entity_root["albedoPath"]);
                }
            }
        }

        object->Transform = glm::mat4(1.0f);
        ImGuizmo::RecomposeMatrixFromComponents(glm::value_ptr(object->Position),
                                                glm::value_ptr(object->Rotation),
                                                glm::value_ptr(object->Scale),
                                                glm::value_ptr(object->Transform));
    }

    for (std::pair<std::string, CPUModel*> pair : modelCache) {
        delete pair.second;
    }
    for (std::pair<std::string, Image*> pair : imageCache) {
        delete pair.second;
    }

    return scene;
}

void SceneSerializer::Serialize(Ref<Scene> scene, const std::string& path)
{
    nlohmann::json root;
    root["sceneName"] = scene->_Name;
    root["entities"] = nlohmann::json::array();
    
    for (auto object : scene->_Objects) {
        nlohmann::json entity_root;
        entity_root["name"] = object->Name;

        entity_root["position"][0] = object->Position.x;
        entity_root["position"][1] = object->Position.y;
        entity_root["position"][2] = object->Position.z;

        entity_root["rotation"][0] = object->Rotation.x;
        entity_root["rotation"][1] = object->Rotation.y;
        entity_root["rotation"][2] = object->Rotation.z;

        entity_root["scale"][0] = object->Scale.x;
        entity_root["scale"][1] = object->Scale.y;
        entity_root["scale"][2] = object->Scale.z;

        entity_root["renderable"] = object->HasRenderable;
        if (object->HasRenderable) {
            entity_root["modelPath"] = object->Renderable.ModelPath;
            if (object->Renderable.Textures[EntityTextureType::Albedo].Valid) {
                entity_root["albedoPath"] = object->Renderable.Textures[EntityTextureType::Albedo].Path;
            } else {
                entity_root["albedoPath"] = "";
            }
        } else {
            entity_root["modelPath"] = "";
            entity_root["albedoPath"] = "";
        }

        root["entities"].push_back(entity_root);
    }

    FileSystem::WriteJSON(path, root);
}
