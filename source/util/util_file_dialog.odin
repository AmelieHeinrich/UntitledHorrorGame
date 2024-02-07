//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 06/02/2024 22:29
//=============================================================================//

package util

import "core:sys/windows"
import "core:log"
import "core:path/filepath"
import "core:strings"

import "vendor:sdl2"

// note(ahi): MESSY AS FUCK LOLLLLLLLLLLLLLLLL
file_dialog_open :: proc(window: ^sdl2.Window, filter: string) -> string {
    wm_info: sdl2.SysWMinfo
    sdl2.GetVersion(&wm_info.version)
    sdl2.GetWindowWMInfo(window, &wm_info)

    target_window: windows.HWND = windows.HWND(wm_info.info.win.window)
    sz_file: [256]windows.WCHAR = {}
    sz_dir: [256]windows.WCHAR = {}
    open: windows.OPENFILENAMEW
    wfilter := windows.utf8_to_wstring(filter)
    defer free(wfilter)

    if windows.GetCurrentDirectoryW(256, &sz_dir[0]) != 0 {
        open.lpstrInitialDir = &sz_dir[0]
    }

    open.lStructSize = size_of(windows.OPENFILENAMEW)
    open.hwndOwner = target_window
    open.lpstrFile = &sz_file[0]
    open.lpstrFilter = wfilter
    open.nMaxFile = 256
    
    result := windows.GetOpenFileNameW(&open)
    if result == true {
        dir_utf8, convert_err := windows.wstring_to_utf8(&sz_dir[0], 256)
        if convert_err != nil {
            log.error("Fuck windows!")
            windows.SetCurrentDirectoryW(&sz_dir[0])
            return ""
        }

        for i in 0..=255 {
            if open.lpstrFile[i] == '\\' {
                open.lpstrFile[i] = '/'
            }
        }
        data, err := windows.wstring_to_utf8(open.lpstrFile, 256)
        if err != nil {
            log.error("Fuck windows!")
            windows.SetCurrentDirectoryW(&sz_dir[0])
            return ""
        }
        new_data, new_err := filepath.rel(dir_utf8, data)
        if new_err != nil {
            log.error("Fuck relative paths!")
            windows.SetCurrentDirectoryW(&sz_dir[0])
            return ""
        }
        clean_data, allocated := strings.replace_all(new_data, "\\", "/")
        windows.SetCurrentDirectoryW(&sz_dir[0])
        return clean_data
    } else {
        windows_error := windows.CommDlgExtendedError()
        log.error("Failed to open file dialog!")
        log.error(windows_error)
    }
    return ""
}
