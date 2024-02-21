/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 11:53:39
 */

#include "logger.hpp"

#include <vector>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/sinks/basic_file_sink.h>

std::shared_ptr<spdlog::logger> Logger::_Logger;

void Logger::Init()
{
    std::vector<spdlog::sink_ptr> logSinks;
    logSinks.emplace_back(CreateRef<spdlog::sinks::stdout_color_sink_mt>());
	logSinks.emplace_back(CreateRef<spdlog::sinks::basic_file_sink_mt>("log.txt", true));

    logSinks[0]->set_pattern("%^[%c] [%l] %n: %v%$");
	logSinks[1]->set_pattern("[%c] [%l] %n: %v");

    _Logger = CreateRef<spdlog::logger>("GAME", begin(logSinks), end(logSinks));
    spdlog::register_logger(_Logger);
    _Logger->set_level(spdlog::level::trace);
    _Logger->flush_on(spdlog::level::trace);
}
