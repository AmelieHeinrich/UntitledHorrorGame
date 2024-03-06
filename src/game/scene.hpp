/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 20:52:39
 */

#pragma once

#include "game_object.hpp"
#include "free_camera.hpp"

class Scene
{
public:
    Scene() = default;
    ~Scene();

    void Update(f64 dt);

    GameObject *NewObject();
    GameObject *DuplicateObject(GameObject *object);
    void AddObject(GameObject *object);
    void RemoveObject(GameObject *object);

    FreeCamera& GetCamera() { return _Camera; }
    std::vector<GameObject*>& GetObjects() { return _Objects; }
    std::string GetPath() { return _Path; }
private:
    friend class SceneSerializer;
    friend class SceneRenderer;
    friend class SceneEditor;

    std::string _Name = "";
    std::string _Path = "";
    FreeCamera _Camera;
    std::vector<GameObject*> _Objects;
};
