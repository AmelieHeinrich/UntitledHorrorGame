/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-20 23:35:01
 */

#include "input_system.hpp"

Input::InputData Input::_Data;

void Input::Init()
{
    _Data.Keys = {};
    _Data.Buttons = {};
    _Data.MousePosition[0] = 0.0f;
    _Data.MousePosition[1] = 0.0f;
    _Data.MouseWheel[0] = 0.0f;
    _Data.MouseWheel[1] = 0.0f;
}

void Input::CompleteFrame()
{
    _Data.MouseWheel[0] = 0.0f;
    _Data.MouseWheel[1] = 0.0f;
}
