/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 11:50:53
 */

#pragma once

#include <spdlog/spdlog.h>
#include <memory>

#include "core.hpp"
#include "memory_tracker.hpp"

class Logger
{
public:
    static void Init();

    static Ref<spdlog::logger> GetLogger() { return _Logger; }
private:
    static Ref<spdlog::logger> _Logger;
};

#define LOG_TRACE(...)    ::Logger::GetLogger()->trace(__VA_ARGS__)
#define LOG_INFO(...)     ::Logger::GetLogger()->info(__VA_ARGS__)
#define LOG_WARN(...)     ::Logger::GetLogger()->warn(__VA_ARGS__)
#define LOG_ERROR(...)    ::Logger::GetLogger()->error(__VA_ARGS__)
#define LOG_CRITICAL(...) ::Logger::GetLogger()->critical(__VA_ARGS__)
