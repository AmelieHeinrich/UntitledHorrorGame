/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:27:53
 */

#pragma once

#include <core/core.hpp>
#include <glm/glm.hpp>

class FreeCamera
{
public:
    FreeCamera();

    void Update(f64 dt);
    void Input(f64 dt);

    glm::mat4 View() { return _View; }
    glm::mat4 Projection() { return _Projection; }
private:
    void UpdateVectors();

    f32 _Yaw;
    f32 _Pitch;
    f32 _FOV;

    glm::vec3 _Position;
    glm::vec3 _Front;
    glm::vec3 _Up;
    glm::vec3 _Right;
    glm::vec3 _WorldUp;

    i32 _MousePos[2];
    bool _FirstMouse;

    glm::mat4 _View;
    glm::mat4 _Projection;
    glm::mat4 _ViewMat;

    f32 _Acceleration;
    f32 _Friction;
    glm::vec3 _Velocity;
    f32 _MaxVelocity;

    i32 _Width;
    i32 _Height;
};
