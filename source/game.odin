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

Game_State :: struct {
    config_file: Config_File,
    config: Config_Data,

    window: Window_State,
    gl_ctx: OpenGL_Context,
    events: Event_System,
};

do_game :: proc() {
    game: Game_State;
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
    if !config_file_load(&game.config_file, "gamedata/game_settings.json") {
        log.error("Failed to load json settings file!")
        return
    }
    defer config_file_destroy(&game.config_file)

    // Create window
    json.unmarshal(game.config_file.file_contents, &game.config)

    game.window.width = i32(game.config.window.width)
    game.window.height = i32(game.config.window.height)

    SDL.Init({.VIDEO})
    defer SDL.Quit()

    game.window.window = SDL.CreateWindow("Duvet", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, game.window.width, game.window.height, {.OPENGL})
    defer SDL.DestroyWindow(game.window.window)

    log.debugf("Created window Duvet with dimensiosn (%d %d)", game.window.width, game.window.height)

    // Init OpenGL Context
    opengl_context_init(&game.gl_ctx, game.window.window, game.config.renderer.vsync)
    defer opengl_context_destroy(&game.gl_ctx)

    // Init event system
    event_system_init(&game.events)
    defer event_system_free(&game.events)

    // TODO(ahi): Init input
    // TODO(ahi): Init audio
    // TODO(ahi): Init graphics
    // TODO(ahi): Init GUI widgets
    // TODO(ahi): Init editor
    // TODO(ahi): Init game

    log.infof("Hello from Duvet! Current game version: %d.%d.%d",
                i32(game.config.version.major),
                i32(game.config.version.revision),
                i32(game.config.version.minor))

    // Main loop
    loop: for {
        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                    break loop
            }
        }

        opengl_context_present(&game.gl_ctx)
    }
}
