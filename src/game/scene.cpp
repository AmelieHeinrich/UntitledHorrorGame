/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 20:55:13
 */

#include "scene.hpp"
#include "game.hpp"

#include <algorithm>

Scene::~Scene()
{
    for (auto object : _Objects) {
        delete object;
    }
    _Objects.clear();
}

void Scene::Update(f64 dt)
{
    if (!state.editorFocused) {
        _Camera.Input(dt);
    }
    _Camera.Update(dt);
}

GameObject *Scene::NewObject()
{
    GameObject* object = new GameObject;
    object->ArrayIndex = _Objects.size();
    _Objects.push_back(object);
    return object;
}

void Scene::AddObject(GameObject *object)
{
    _Objects.push_back(object);
}

void Scene::RemoveObject(GameObject *object)
{
    _Objects.erase(std::find(_Objects.begin(), _Objects.end(), object));
    delete object;
}
