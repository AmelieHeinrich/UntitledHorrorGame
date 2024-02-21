/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:39:09
 */

#pragma once

#include "game_object.hpp"
#include "scene.hpp"

class SceneEditor
{
public:
    static bool Manipulate(Ref<Scene>& scene);

private:
    struct SceneEditorData
    {
        GameObject* SelectedObject = nullptr;
        bool ObjectSelected = false;
        std::string SelectedFile; // NOTE(ahi): For hot reloading purposes!!
    };

    static SceneEditorData Data;
};
