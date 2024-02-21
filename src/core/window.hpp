/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 13:37:54
 */

#pragma once

#include "core.hpp"

#include <GLFW/glfw3.h>

class Window
{
public:
    Window(i32 width, i32 height);
    ~Window();

    bool Open();
    void Update();
    void PollSize(i32 *width, i32 *height);

    GLFWwindow* GetGLFWWindow() { return _Window; }
    void* GetNativeWindow();
private:
    GLFWwindow *_Window;
};
