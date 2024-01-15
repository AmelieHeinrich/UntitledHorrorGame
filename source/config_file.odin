//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 15/01/2024 13:59
//=============================================================================//

package duvet

import "core:log"
import "core:os"
import "core:encoding/json"

Config_File :: struct {
    data: json.Value,
    path: string,
}

config_file_load :: proc(file: ^Config_File, path: string) -> bool {
    data, ok := os.read_entire_file_from_filename(path)
    if !ok {
        log.errorf("Failed to load config file of pâth %s", path)
        return false
    }
    defer delete(data)

    json_data, err := json.parse(data)
    if err != .None {
        log.errorf("Failed to parse json data in file %s", path)
        log.error(err)
        return false
    }

    file.data = json_data
    file.path = path
    return true
}

config_file_destroy :: proc(file: ^Config_File) {
    opt: json.Marshal_Options
    opt.pretty = true

    data, err := json.marshal(file.data, opt)
    if err != nil {
        log.errorf("Failed to convert json data back to bytes")
        log.error(err)
        return
    }
    defer delete(data)

    ok := os.write_entire_file(file.path, data)
    if !ok {
        log.errorf("Failed to write json string to file %s", file.path)
    }
    json.destroy_value(file.data)
}
