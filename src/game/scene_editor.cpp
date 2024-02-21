/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:42:11
 */

#include "scene_editor.hpp"
#include "scene_serializer.hpp"
#include "reload_queue.hpp"

#include <imgui/imgui.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include <util/file_dialog.hpp>

SceneEditor::SceneEditorData SceneEditor::Data;

bool SceneEditor::Manipulate(Ref<Scene> scene)
{
    ImGui::Begin("Scene Panel");
    bool focused = ImGui::IsWindowFocused();

    ImGui::Text("Editing scene %s", scene->_Name.c_str());
    if (ImGui::Button("Save")) {
        SceneSerializer::Serialize(scene, scene->_Path);
    }
    ImGui::Separator();

    ImGui::Text("Entity List");
    for (int i = 0; i < scene->_Objects.size(); i++) {
        GameObject *object = &scene->_Objects[i];
        if (ImGui::Selectable(object->Name.c_str())) {
            Data.ObjectSelected = true;
            Data.SelectedObject = object;
        }
    }

    if (Data.ObjectSelected) {
        ImGui::Separator();
        // TODO: Change entity name
        ImGui::Text("%s", Data.SelectedObject->Name.c_str());

        ImGui::Separator();
        ImGui::DragFloat3("Position", glm::value_ptr(Data.SelectedObject->Position));
        ImGui::DragFloat3("Rotation", glm::value_ptr(Data.SelectedObject->Rotation));
        ImGui::DragFloat3("Scale", glm::value_ptr(Data.SelectedObject->Scale));

        if (Data.SelectedObject->HasRenderable) {
            ImGui::Text("Mesh: %s", Data.SelectedObject->Renderable.ModelPath.c_str());
            ImGui::SameLine();
            if (ImGui::Button("Load Model")) {
                std::string path = FileDialog::Open("");
                if (path.length() > 0) {
                    ReloadRequest request;
                    request.Object = Data.SelectedObject;
                    request.Path = path;
                    request.Type = ReloadRequestType::Model;
                    ReloadQueue::PushRequest(request);
                }
            }

            ImGui::Text("Albedo: %s", Data.SelectedObject->Renderable.Textures[EntityTextureType::Albedo].Path.c_str());
            ImGui::SameLine();
            if (ImGui::Button("Load Texture")) {
                std::string path = FileDialog::Open("");
                if (path.length() > 0) {
                    ReloadRequest request;
                    request.Object = Data.SelectedObject;
                    request.Path = path;
                    request.Type = ReloadRequestType::Albedo;
                    ReloadQueue::PushRequest(request);
                }
            }
        }
    }

    ImGui::End();
    return focused;
}
