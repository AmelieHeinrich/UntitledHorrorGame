/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 22:57:13
 */

#pragma once

#include "core.hpp"

#include <unordered_map>
#include <GLFW/glfw3.h>

enum KeyState
{
    KEY_RELEASED,
    KEY_PRESSED,
    KEY_REPEAT
};

class Input
{
public:
    static void Init();
    static void CompleteFrame();

    static void HandleKey(u32 key, KeyState state) { _Data.Keys[key] = state; }
    static void HandleButton(u32 button, bool state) { _Data.Buttons[button] = state; }
    static void HandlePosition(i32 x, i32 y) { _Data.MousePosition[0] = x; _Data.MousePosition[1] = y; }
    static void HandleWheel(i32 x, i32 y) { _Data.MouseWheel[0] = x; _Data.MouseWheel[1] = y; }

    static bool IsKeyPressed(u32 key) { return _Data.Keys[key] == KEY_PRESSED; }
    static bool IsKeyHeld(u32 key) { return _Data.Keys[key] == KEY_PRESSED || _Data.Keys[key] == KEY_REPEAT; }
    static bool IsKeyReleased(u32 key) { return _Data.Keys[key] == KEY_RELEASED; }
    static bool IsKeyRepeat(u32 key) { return _Data.Keys[key] == KEY_REPEAT; }

    static bool IsButtonPressed(u32 button) { return _Data.Buttons[button] == true; }
    static bool IsButtonReleased(u32 button) { return _Data.Buttons[button] == false; }

    static void GetMousePosition(i32 *x, i32 *y) { *x = _Data.MousePosition[0]; *y = _Data.MousePosition[1]; }
    static void GetMouseWheel(i32 *x, i32 *y) { *x = _Data.MouseWheel[0]; *y = _Data.MouseWheel[1]; }
private:
    struct InputData
    {
        std::unordered_map<u32, KeyState> Keys;
        std::unordered_map<u32, bool> Buttons;
        i32 MousePosition[2];
        i32 MouseWheel[2];
    };

    static InputData _Data;
};
