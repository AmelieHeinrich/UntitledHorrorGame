/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 13:42:46
 */

#include "window.hpp"
#include "logger.hpp"
#include "input_system.hpp"
#include "game.hpp"

#include <game.hpp>
#include <renderer/context.hpp>

#define GLFW_EXPOSE_NATIVE_WIN32
#include <GLFW/glfw3native.h>

static void KeyCallback(GLFWwindow *window, int key, int scancode, int action, int mods)
{
    if (action == GLFW_PRESS) {
        Input::HandleKey(key, KEY_PRESSED);
    } else if (action == GLFW_RELEASE) {
        Input::HandleKey(key, KEY_RELEASED);
    } else {
        Input::HandleKey(key, KEY_REPEAT);
    }
}

static void ButtonCallback(GLFWwindow* window, int button, int action, int mods)
{
    if (action == GLFW_PRESS) {
        Input::HandleButton(button, true);
    } else if (action == GLFW_RELEASE) {
        Input::HandleButton(button, false);
    }
}

static void PositionCallback(GLFWwindow* window, double xpos, double ypos)
{
    Input::HandlePosition(i32(xpos), i32(ypos));
}

static void ScrollCallback(GLFWwindow* window, double xoffset, double yoffset)
{
    Input::HandleWheel(i32(xoffset), i32(yoffset));
}

static void ResizeCallback(GLFWwindow* window, i32 width, i32 height)
{
    state.width = width;
    state.height = height;
    RenderContext::Resize(width, height);
}

Window::Window(i32 width, i32 height)
{
    if (!glfwInit()) {
        LOG_ERROR("Failed to initialise GLFW!");
    }

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);

    // TODO: Borderless fullscreen and fullscreen
    _Window = glfwCreateWindow(width, height, "A Love Letter to Hate | <D3D11>", nullptr, nullptr);
    if (!_Window) {
        LOG_ERROR("Failed to create window!");
    }

    glfwSetKeyCallback(_Window, KeyCallback);
    glfwSetMouseButtonCallback(_Window, ButtonCallback);
    glfwSetCursorPosCallback(_Window, PositionCallback);
    glfwSetScrollCallback(_Window, ScrollCallback);
    glfwSetWindowSizeCallback(_Window, ResizeCallback);
}

Window::~Window()
{
    glfwDestroyWindow(_Window);
    glfwTerminate();
}

bool Window::Open()
{
    return !glfwWindowShouldClose(_Window);
}

void Window::Update()
{
    glfwPollEvents();
}

void Window::PollSize(i32 *width, i32 *height)
{
    if (_Window) {
        glfwGetWindowSize(_Window, width, height);
    }
}

void Window::SetFullscreen(bool fullscreen)
{
    if (fullscreen) {
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        const GLFWvidmode* mode = glfwGetVideoMode(monitor);
        glfwSetWindowMonitor(_Window, monitor, 0, 0, mode->width, mode->height, mode->refreshRate);
        _Width = mode->width;
        _Height = mode->height;
        state.width = mode->width;
        state.height = mode->height;
    } else {
        glfwSetWindowMonitor(_Window, NULL, 0, 0, _Width, _Height, 0);
    }
}

void* Window::GetNativeWindow()
{
    return glfwGetWin32Window(_Window);
}
