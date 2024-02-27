/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:42:11
 */

#include "scene_editor.hpp"
#include "scene_serializer.hpp"
#include "reload_queue.hpp"
#include "game.hpp"
#include "core/memory_tracker.hpp"

#include <core/logger.hpp>
#include <core/input_system.hpp>

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include <util/file_dialog.hpp>

#include <sstream>

SceneEditor::SceneEditorData SceneEditor::Data;

bool SceneEditor::Manipulate(Ref<Scene>& scene)
{
    glm::mat4 identity(1.0f);
    bool focused = false;
    ImGuiIO& io = ImGui::GetIO();

    if (Input::IsKeyPressed(GLFW_KEY_ESCAPE)) {
        Data.SelectedObject = nullptr;
        Data.ObjectSelected = false;
    }

    // Guizmo context
    ImGui::SetNextWindowPos({0, 0});
    ImGui::SetNextWindowSize({f32(state.width), f32(state.height)});
    ImGui::Begin("ImGuizmo Context", nullptr, ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoInputs);

    ImGuizmo::SetOrthographic(false);
    ImGuizmo::SetDrawlist();
    ImGuizmo::SetRect(0, 0, io.DisplaySize.x, io.DisplaySize.y);
    if (Data.DrawGrid) {
        ImGuizmo::DrawGrid(glm::value_ptr(scene->_Camera.View()),
                           glm::value_ptr(scene->_Camera.Projection()),
                           glm::value_ptr(identity),
                           100.0f);
    }
    if (Data.ObjectSelected) {
        ImGuizmo::RecomposeMatrixFromComponents(glm::value_ptr(Data.SelectedObject->Position),
                                                glm::value_ptr(Data.SelectedObject->Rotation),
                                                glm::value_ptr(Data.SelectedObject->Scale),
                                                glm::value_ptr(Data.SelectedObject->Transform));

        focused = ImGuizmo::Manipulate(glm::value_ptr(scene->_Camera.View()),
                             glm::value_ptr(scene->_Camera.Projection()),
                             Data.Operation,
                             ImGuizmo::MODE::WORLD,
                             glm::value_ptr(Data.SelectedObject->Transform),
                             nullptr,
                             nullptr);

        ImGuizmo::DecomposeMatrixToComponents(glm::value_ptr(Data.SelectedObject->Transform),
                                              glm::value_ptr(Data.SelectedObject->Position),
                                              glm::value_ptr(Data.SelectedObject->Rotation),
                                              glm::value_ptr(Data.SelectedObject->Scale));
    }
    ImGui::End();

    ImGui::Begin("Scene Panel");
    focused = focused || ImGui::IsWindowFocused();

    // Guizmo control
    {
        if (ImGui::RadioButton("Translate", Data.Operation == ImGuizmo::OPERATION::TRANSLATE))
            Data.Operation = ImGuizmo::OPERATION::TRANSLATE;
        ImGui::SameLine();
        if (ImGui::RadioButton("Scale", Data.Operation == ImGuizmo::OPERATION::SCALE))
            Data.Operation = ImGuizmo::OPERATION::SCALE;
        ImGui::SameLine();
        if (ImGui::RadioButton("Rotate", Data.Operation == ImGuizmo::OPERATION::ROTATE))
            Data.Operation = ImGuizmo::OPERATION::ROTATE;
    }
    ImGui::Separator();

    ImGui::Checkbox("Draw Grid", &Data.DrawGrid);
    ImGui::Separator();

    // Scene dialogs
    {
        ImGui::Text("Editing scene %s", scene->_Name.c_str());
        {
            char buffer[256];
            strcpy(buffer, scene->_Name.c_str());
            ImGui::InputText("Scene Name", buffer, 256);
            scene->_Name = std::string(buffer);
        }
        if (ImGui::Button("Save")) {
            SceneSerializer::Serialize(scene, scene->_Path);
        }
        ImGui::SameLine();
        if (ImGui::Button("Save As")) {
            std::string path = FileDialog::Save("");
            if (path.length() > 0) {
                SceneSerializer::Serialize(scene, path);
            }
        }
        ImGui::SameLine();
        if (ImGui::Button("New Scene")) {
            std::string path = FileDialog::Save("");
            if (path.length() > 0) {
                SceneSerializer::Serialize(scene, scene->_Path);
                scene.reset();

                scene = CreateRef<Scene>();
                scene->_Name = "New Scene";
                scene->_Path = path;
                SceneSerializer::Serialize(scene, path);
                scene = SceneSerializer::Deserialize(path);
            }
        }
        ImGui::SameLine();
        if (ImGui::Button("Load")) {
            std::string path = FileDialog::Open("");
            if (path.length() > 0) {
                SceneSerializer::Serialize(scene, scene->_Path);
                scene.reset();

                scene = SceneSerializer::Deserialize(path);
            }
        }
        ImGui::Separator();
    }

    // Scene panel
    {
        if (Data.ObjectSelected) {
            bool removeEntity = false;
            ImGui::Separator();

            char buffer[256];
            strcpy(buffer, Data.SelectedObject->Name.c_str());
            ImGui::InputText("Name", buffer, 256);
            Data.SelectedObject->Name = std::string(buffer);

            if (ImGui::Button("Remove Entity")) {
                removeEntity = true;
            }
            if (ImGui::Button("Duplicate Entity")) {
                scene->DuplicateObject(Data.SelectedObject);
            }

            ImGui::Separator();
            ImGui::DragFloat3("Position", glm::value_ptr(Data.SelectedObject->Position));
            ImGui::DragFloat3("Rotation", glm::value_ptr(Data.SelectedObject->Rotation));
            ImGui::DragFloat3("Scale", glm::value_ptr(Data.SelectedObject->Scale));

            if (Data.SelectedObject->HasRenderable) {
                if (ImGui::Button("Remove Renderable")) {
                    Data.SelectedObject->FreeRender();
                }

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
            } else {
                if (ImGui::Button("Add Renderable")) {
                    Data.SelectedObject->InitRender("gamedata/assets/models/Cube.gltf");
                }
            }

            if (removeEntity) {
                scene->RemoveObject(Data.SelectedObject);
                Data.SelectedObject = nullptr;
                Data.ObjectSelected = false;
            }
        }
    }

    ImGui::End();

    ImGui::Begin("Entity List");
    focused = focused || ImGui::IsWindowFocused();
    if (ImGui::Button("New Entity")) {
        GameObject *object = scene->NewObject();
        object->Name = "New Entity";
    }

    for (int i = 0; i < scene->_Objects.size(); i++) {
       GameObject *object = scene->_Objects[i];
       std::stringstream ss;
       ss << "> " << object->Name.c_str();
       if (ImGui::Selectable(ss.str().c_str())) {
           Data.ObjectSelected = true;
           Data.SelectedObject = object;
       }
    }
    ImGui::End();

    ImGui::Begin("Statistics");
    focused = focused || ImGui::IsWindowFocused();
    if (ImGui::TreeNode("Memory Footprint")) {
        ImGui::Text("ASSETS: %fmb", BYTES_TO_MEGABYTES(MemoryTracker::GetUsedMemory(MemoryDomain::ASSETS)));
        ImGui::Text("SCENE: %fmb", BYTES_TO_MEGABYTES(MemoryTracker::GetUsedMemory(MemoryDomain::SCENE)));
        ImGui::Text("TEXTURES: %fgb", BYTES_TO_GIGABYTES(MemoryTracker::GetUsedMemory(MemoryDomain::TEXTURES)));
        ImGui::Text("BUFFERS: %fgb", BYTES_TO_GIGABYTES(MemoryTracker::GetUsedMemory(MemoryDomain::BUFFERS)));
        ImGui::TreePop();
    }
    ImGui::End();

    return focused;
}
