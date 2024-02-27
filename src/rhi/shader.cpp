/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-19 14:31:48
 */

#include "shader.hpp"
#include "context.hpp"

#include <d3dcompiler.h>

#include <core/logger.hpp>
#include <core/file_system.hpp>

ShaderBytecode ShaderCompiler::ReadDXIL(const std::string& path)
{
    ShaderBytecode result = {};

    u32 size = FileSystem::GetFileSize(path);
    u8* byte = reinterpret_cast<u8*>(FileSystem::ReadBytes(path));

    result.bytecode.resize(size / sizeof(u32));
    memcpy(result.bytecode.data(), byte, size);
    delete[] byte;

    return result;
}

ShaderBytecode ShaderCompiler::CompileFromFile(const std::string& path, const std::string& profile)
{
    std::string source = FileSystem::ReadFile(path);
    return CompileToDXIL(source, profile);
}

ShaderBytecode ShaderCompiler::CompileToDXIL(const std::string& source, const std::string& profile)
{
    ShaderBytecode result = {};

    ID3DBlob* shaderBlob = nullptr;
    ID3DBlob* errorBlob = nullptr;
    HRESULT status = D3DCompile(source.c_str(), source.size(), nullptr, nullptr, D3D_COMPILE_STANDARD_FILE_INCLUDE, "main", profile.c_str(), 0, 0, &shaderBlob, &errorBlob);
    if (errorBlob) {
        LOG_ERROR("Shader error (profile: {0}) : {1}", profile.c_str(), (char*)errorBlob->GetBufferPointer());
    }

    result.bytecode.resize(shaderBlob->GetBufferSize() / sizeof(u32));
    memcpy(result.bytecode.data(), shaderBlob->GetBufferPointer(), shaderBlob->GetBufferSize());
    SafeRelease(shaderBlob);
    SafeRelease(errorBlob);

    return result;
}
