//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 20/01/2024 18:28
//=============================================================================//

package game

import "core:strings"
import "core:fmt"
import "core:os"

Virtual_File_System :: struct {
    paths: [dynamic]string
}

virtual_file_system: Virtual_File_System

virtual_file_system_init :: proc() {
    virtual_file_system.paths = make([dynamic]string)
}

virtual_file_system_free :: proc() {
    delete(virtual_file_system.paths)
}

virtual_file_system_mount :: proc(path: string) {
    append(&virtual_file_system.paths, path)
}

vfs :: proc(path: string) -> string {
    b: strings.Builder
    strings.builder_init(&b)

    result: string
    for mounted in virtual_file_system.paths {
        strings.builder_reset(&b)
        fmt.sbprintf(&b, "%s%s", mounted, path)
        if (os.exists(strings.to_string(b))) {
            result = strings.to_string(b)
            break
        } else {
            result = path
        }
    }
    strings.builder_destroy(&b)
    return result
}
