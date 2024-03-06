/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:57:36
 */

#include "free_camera.hpp"
#include "game.hpp"

#include <glm/trigonometric.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <core/input_system.hpp>

FreeCamera::FreeCamera()
    : _Up(0.0f, -1.0f, 1.0f),
      _Front(0.0f, 0.0f, -1.0f),
      _WorldUp(0.0f, 1.0f, 0.0f),
      _Position(0.0f, 0.0f, 1.0f),
      _Yaw(-90.0f),
      _Pitch(0.0f),
      _Friction(10.0f),
      _Acceleration(20.0f),
      _MaxVelocity(15.0f),
      _FOV(90.0f)
{
    UpdateVectors();
}

void FreeCamera::Update(f64 dt)
{
    state.window->PollSize(&_Width, &_Height);
    Input::GetMousePosition(&_MousePos[0], &_MousePos[1]);

    _View = glm::lookAt(_Position, _Position + _Front, _WorldUp);
    _Projection = glm::perspective(_FOV, f32(_Width) / f32(_Height), 0.05f, 10000.0f);
}

void FreeCamera::Input(f64 dt)
{
    f32 speedMultiplier = _Acceleration * dt;
    if (Input::IsKeyHeld(GLFW_KEY_W)) {
        _Velocity += _Front * speedMultiplier;
    } else if (Input::IsKeyHeld(GLFW_KEY_S)) {
        _Velocity -= _Front * speedMultiplier;
    }
    if (Input::IsKeyHeld(GLFW_KEY_A)) {
        _Velocity -= _Right * speedMultiplier;
    } else if (Input::IsKeyHeld(GLFW_KEY_D)) {
        _Velocity += _Right * speedMultiplier;
    }

    f32 friction_multiplier = 1.0f / (1.0f + (_Friction * dt));
    _Velocity *= friction_multiplier;

    f32 length = glm::length(_Velocity);
    if (length > _MaxVelocity) {
        _Velocity = glm::normalize(_Velocity) * _MaxVelocity;
    }
    _Position += _Velocity * glm::vec3(dt, dt, dt);

    int x, y;
    Input::GetMousePosition(&x, &y);

    f32 dx = (x - _MousePos[0]) * 0.1f;
    f32 dy = (y - _MousePos[1]) * 0.1f;

    if (Input::IsButtonPressed(GLFW_MOUSE_BUTTON_LEFT)) {
        _Yaw += dx;
        _Pitch -= dy;
    }

    UpdateVectors();
}

void FreeCamera::UpdateVectors()
{
    glm::vec3 front;
    front.x = glm::cos(glm::radians(_Yaw)) * glm::cos(glm::radians(_Pitch));
    front.y = glm::sin(glm::radians(_Pitch));
    front.z = glm::sin(glm::radians(_Yaw)) * glm::cos(glm::radians(_Pitch));
    _Front = glm::normalize(front);
    _Right = glm::normalize(glm::cross(_Front, _WorldUp));
    _Up = glm::normalize(glm::cross(_Right, _Front));
}
