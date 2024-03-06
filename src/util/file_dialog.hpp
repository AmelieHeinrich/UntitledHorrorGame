/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:51:55
 */

#pragma once

#include <string>

class FileDialog
{
public:
    static std::string Open(const std::string& filter);
    static std::string Save(const std::string& filter);
};
