/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:39:09
 */

#pragma once

#include "game_object.hpp"
#include "scene.hpp"

#include <imgui/imgui.h>
#include <imguizmo/ImGuizmo.h>

class SceneEditor
{
public:
    static bool Manipulate(Ref<Scene>& scene);

private:
    struct SceneEditorData
    {
        GameObject* SelectedObject = nullptr;
        bool ObjectSelected = false;
        ImGuizmo::OPERATION Operation = ImGuizmo::OPERATION::TRANSLATE;
        bool DrawGrid = false;
    };

    static SceneEditorData Data;
};
