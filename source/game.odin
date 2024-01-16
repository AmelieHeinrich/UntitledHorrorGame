//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package duvet

import "core:fmt"
import "core:log"
import "core:os"
import "core:encoding/json"
import "core:mem"

import SDL "vendor:sdl2"

Window_State :: struct {
    width: i32,
    height: i32,
    window: ^SDL.Window,
};

Config_Data :: struct {
    renderer: struct {
        vsync: bool,
        api: string
    },
    version: struct {
        minor: f32,
        major: f32,
        revision: f32
    },
    window: struct {
        type: string,
        width: f32,
        height: f32
    }
};

do_game :: proc() {
    window_state: Window_State;
    config_file: Config_File;
    config_data: Config_Data;

    // Init logger
    handle, err := os.open("gamedata/log.txt", os.O_CREATE | os.O_TRUNC)
    if err != 0 {
        fmt.eprintln("[ERROR] Failed to create log file!")
        return
    }
    defer os.close(handle)

    console_logger := log.create_console_logger()
    defer log.destroy_console_logger(console_logger)

    file_logger := log.create_file_logger(handle)
    defer log.destroy_file_logger(&file_logger)

    multi_logger := log.create_multi_logger(console_logger, file_logger)
    defer log.destroy_multi_logger(&multi_logger)

    context.logger = multi_logger

    // Init config file
    if !config_file_load(&config_file, "gamedata/game_settings.json") {
        log.error("Failed to load json settings file!")
        return
    }
    defer config_file_destroy(&config_file)

    // Create window
    json.unmarshal(config_file.file_contents, &config_data)

    window_state.width = i32(config_data.window.width)
    window_state.height = i32(config_data.window.height)

    SDL.Init({.VIDEO})
    defer SDL.Quit()

    window_state.window = SDL.CreateWindow("Duvet", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, window_state.width, window_state.height, {.OPENGL})
    defer SDL.DestroyWindow(window_state.window)

    log.infof("Hello from Duvet! Current game version: %d.%d.%d",
                i32(config_data.version.major),
                i32(config_data.version.revision),
                i32(config_data.version.minor))
    log.infof("Created window of title Duvet and of size (%d, %d)", window_state.width, window_state.height)

    // TODO(ahi): Init event
    // TODO(ahi): Init input
    // TODO(ahi): Init audio
    // TODO(ahi): Init graphics
    // TODO(ahi): Init GUI widgets
    // TODO(ahi): Init editor
    // TODO(ahi): Init game

    // Main loop
    loop: for {
        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                    break loop
            }
        }
    }
}
