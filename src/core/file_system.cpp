/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 12:35:07
 */

#include "file_system.hpp"
#include "logger.hpp"
#include "core.hpp"

#include <sys/stat.h>
#include <fstream>

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

bool FileSystem::Exists(const std::string& path)
{
    struct stat statistics;
    if (stat(path.c_str(), &statistics) == -1)
        return false;
    return true;
}

bool FileSystem::IsDirectory(const std::string& path)
{
    struct stat statistics;
    if (stat(path.c_str(), &statistics) == -1)
        return false;
    return (statistics.st_mode & S_IFDIR) != 0;
}

void FileSystem::CreateFileFromPath(const std::string& path)
{
    HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (!handle) {
        LOG_ERROR("Error when creating file {0}", path.c_str());
        return;
    }
    CloseHandle(handle);
}

void FileSystem::CreateDirectoryFromPath(const std::string& path)
{
    if (!CreateDirectoryA(path.c_str(), nullptr)) {
        LOG_ERROR("Error when creating directory {0}", path.c_str());
    }
}

void FileSystem::Delete(const std::string& path)
{
    if (!Exists(path)) {
        LOG_WARN("Trying to delete file {0} that doesn't exist!", path.c_str());
        return;
    }

    if (!DeleteFileA(path.c_str())) {
        LOG_ERROR("Failed to delete file {0}", path.c_str());
    }
}

void FileSystem::Move(const std::string& oldPath, const std::string& newPath)
{
    if (!Exists(oldPath)) {
        LOG_WARN("Trying to move file {0} that doesn't exist!", oldPath.c_str());
        return;
    }

    if (!MoveFileA(oldPath.c_str(), newPath.c_str())) {
        LOG_ERROR("Failed to move file {0} to {1}", oldPath.c_str(), newPath.c_str());
    }
}

void FileSystem::Copy(const std::string& oldPath, const std::string& newPath, bool overwrite)
{
    if (!Exists(oldPath)) {
        LOG_WARN("Trying to copy file {0} that doesn't exist!", oldPath.c_str());
        return;
    }

    if (!CopyFileA(oldPath.c_str(), newPath.c_str(), !overwrite)) {
        LOG_ERROR("Failed to copy file {0} to {1}", oldPath.c_str(), newPath.c_str());
    }
}

i32 FileSystem::GetFileSize(const std::string& path)
{
    i32 result = 0;

    HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (!handle) {
        LOG_ERROR("File {0} does not exist!", path.c_str());
        return 0;
    }
    result = ::GetFileSize(handle, nullptr);
    CloseHandle(handle);
    return result;
}

std::string FileSystem::ReadFile(const std::string& path)
{
    HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (!handle)
    {
        LOG_ERROR("File {0} does not exist and cannot be read!", path);
        return std::string("");
    }
    i32 size = FileSystem::GetFileSize(path);
    if (size == 0)
    {
        LOG_ERROR("File  has a size of 0, thus cannot be read!", path);
        return std::string("");
    }
    i32 bytesRead = 0;
    i8 *buffer = new i8[size + 1];
    ::ReadFile(handle, reinterpret_cast<LPVOID>(buffer), size, reinterpret_cast<LPDWORD>(&bytesRead), nullptr);
    buffer[size] = '\0';
    CloseHandle(handle);
    return std::string(buffer);
}

void *FileSystem::ReadBytes(const std::string& path)
{
    HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (!handle)
    {
        LOG_ERROR("File {0} does not exist and cannot be read!", path);
        return nullptr;
    }
    i32 size = FileSystem::GetFileSize(path);
    if (size == 0)
    {
        LOG_ERROR("File  has a size of 0, thus cannot be read!", path);
        return nullptr;
    }
    i32 bytesRead = 0;
    i8 *buffer = new i8[size + 1];
    ::ReadFile(handle, reinterpret_cast<LPVOID>(buffer), size, reinterpret_cast<LPDWORD>(&bytesRead), nullptr);
    CloseHandle(handle);
    return buffer;
}

nlohmann::json FileSystem::ParseJSON(const std::string& path)
{
    std::ifstream stream(path);
    if (!stream.is_open()) {
        LOG_ERROR("Failed to load json file {}", path.c_str());
        return nlohmann::json::parse("{}");
    }
    nlohmann::json document = nlohmann::json::parse(stream);
    stream.close();
    return document;
}

void FileSystem::WriteJSON(const std::string& path, const nlohmann::json& JSON)
{
    std::ofstream stream(path);
    if (!stream.is_open()) {
        LOG_ERROR("Failed to write json file {}", path.c_str());
        return;
    }
    stream << JSON.dump(4) << std::endl;
    stream.close();
}
