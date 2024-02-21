/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 22:52:33
 */

#include "file_dialog.hpp"
#include "game.hpp"

#include <core/logger.hpp>
#include <filesystem>
#include <algorithm>

#include <Windows.h>
#include <commdlg.h>

std::string FileDialog::Open(const std::string& filter)
{
    HWND nativeWindow = reinterpret_cast<HWND>(state.window->GetNativeWindow());

    CHAR szFile[256] = {};
    CHAR szDir[256] = {};
    GetCurrentDirectoryA(256, szDir);

    OPENFILENAMEA open = {};
    open.lStructSize = sizeof(OPENFILENAMEA);
    open.lpstrInitialDir = szDir;
    open.hwndOwner = nativeWindow;
    open.lpstrFile = szFile;
    open.lpstrFilter = filter.c_str();
    open.nMaxFile = 256;
    open.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR;

    HRESULT result = GetOpenFileNameA(&open);
    if (FAILED(result)) {
        LOG_ERROR("Failed to open file dialog!");
        return "";
    } else {
        std::filesystem::path path = open.lpstrFile;
        std::filesystem::path rootPath = open.lpstrInitialDir;
        path = path.lexically_relative(rootPath);
        std::string string_path = path.string();
        std::replace(string_path.begin(), string_path.end(), '\\', '/');
        return string_path;
    }
}

std::string FileDialog::Save(const std::string& filter)
{
    HWND nativeWindow = reinterpret_cast<HWND>(state.window->GetNativeWindow());

    CHAR szFile[256] = {};
    CHAR szDir[256] = {};
    GetCurrentDirectoryA(256, szDir);

    OPENFILENAMEA open = {};
    open.lStructSize = sizeof(OPENFILENAMEA);
    open.lpstrInitialDir = szDir;
    open.hwndOwner = nativeWindow;
    open.lpstrFile = szFile;
    open.lpstrFilter = filter.c_str();
    open.nMaxFile = 256;
    open.Flags = OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT | OFN_NOCHANGEDIR;

    HRESULT result = GetSaveFileNameA(&open);
    if (FAILED(result)) {
        LOG_ERROR("Failed to save file dialog!");
        return "";
    } else {
        std::filesystem::path path = open.lpstrFile;
        std::filesystem::path rootPath = open.lpstrInitialDir;
        path = path.lexically_relative(rootPath);
        std::string string_path = path.string();
        std::replace(string_path.begin(), string_path.end(), '\\', '/');
        return string_path;
    }
}
