/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 20:55:13
 */

#include "scene.hpp"
#include "game.hpp"

#include <algorithm>

Scene::~Scene()
{
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
    GameObject object;
    object.ArrayIndex = _Objects.size();
    _Objects.push_back(object);
    return &_Objects[object.ArrayIndex];
}

void Scene::AddObject(GameObject *object)
{
    _Objects.push_back(*object);
}

void Scene::RemoveObject(GameObject *object)
{
    _Objects.erase(_Objects.begin() + object->ArrayIndex);
}
