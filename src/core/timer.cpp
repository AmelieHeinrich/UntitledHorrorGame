/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:48:11
 */

#include "timer.hpp"

#include <GLFW/glfw3.h>

Timer::Timer()
{
    _Start = glfwGetTime();
}

void Timer::Restart()
{
    _Start = glfwGetTime();
    _Time = 0.0f;
}

void Timer::Tick()
{
    if (!_Paused) {
        _Time = glfwGetTime() - _Start;
    }
}

void Timer::Pause()
{
    _Paused = !_Paused;
}

f64 Timer::GetGlobalTime()
{
    return glfwGetTime();
}
