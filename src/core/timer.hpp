/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 00:30:37
 */

#pragma once

#include "core.hpp"

class Timer
{
public:
    Timer();

    void Restart();
    void Tick();
    void Pause();

    f64 Get() { return _Time; }

    static f64 GetGlobalTime();
private:
    bool _Paused = false;
    f64 _Start;
    f64 _Time = 0.0f;
};
