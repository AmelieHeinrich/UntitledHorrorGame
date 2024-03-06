/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 14:30:32
 */

#pragma once

#include <core/core.hpp>
#include <string>
#include <vector>

struct ShaderBytecode
{
    std::vector<u32> bytecode;
};

class ShaderCompiler
{
public:
    static ShaderBytecode ReadDXIL(const std::string& path);
    static ShaderBytecode CompileFromFile(const std::string& path, const std::string& profile);
    static ShaderBytecode CompileToDXIL(const std::string& source, const std::string& profile);
};
