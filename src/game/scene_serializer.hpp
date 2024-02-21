/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 21:35:42
 */

#pragma once

#include <core/core.hpp>

#include "scene.hpp"

class SceneSerializer
{
public:
    static Ref<Scene> Deserialize(const std::string& path);
    static void Serialize(Ref<Scene> scene, const std::string& path);
};
