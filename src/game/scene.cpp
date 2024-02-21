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

    for (int i = 0; i < _Objects.size(); i++) {
        GameObject *object = &_Objects[i];

        object->Transform = glm::mat4(1.0f);
        object->Transform = glm::translate(glm::mat4(1.0f), object->Position);
        if (object->Rotation.x != 0.0f) {
            object->Transform *= glm::rotate(glm::mat4(1.0f), glm::radians(object->Rotation.x), glm::vec3(1.0f, 0.0f, 0.0f));
        }
        if (object->Rotation.y != 0.0f) {
            object->Transform *= glm::rotate(glm::mat4(1.0f), glm::radians(object->Rotation.y), glm::vec3(0.0f, 1.0f, 0.0f));
        }
        if (object->Rotation.z != 0.0f) {
            object->Transform *= glm::rotate(glm::mat4(1.0f), glm::radians(object->Rotation.z), glm::vec3(0.0f, 0.0f, 1.0f));
        }
        object->Transform *= glm::scale(glm::mat4(1.0f), object->Scale);
    }
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
