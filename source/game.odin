//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package game

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
    if os.exists("gamedata/log.txt") {
        os.remove("gamedata/log.txt")
    }
    // TODO: check values of os.S_IRUSR | os.S_IRGRP | os.S_IROTH so I can pipe it in for linux :3
    handle, err := os.open("gamedata/log.txt", os.O_CREATE | os.O_RDWR)
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

    game.window.window = SDL.CreateWindow("Untitled Horror Game", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, game.window.width, game.window.height, {.OPENGL})
    defer SDL.DestroyWindow(game.window.window)

    log.debugf("Created window Untitled Horror Game with dimensiosn (%d %d)", game.window.width, game.window.height)

    // Init OpenGL Context
    opengl_context_init(&game.gl_ctx, game.window.window, game.config.renderer.vsync)
    defer opengl_context_destroy(&game.gl_ctx)

    // Init event system
    event_system_init(&game.events)
    defer event_system_free(&game.events)

    // TODO(ahi): Init input
    input_system_init()
    defer input_system_free()

    // TODO(ahi): Init asset system

    // TODO(ahi): Init audio
    
    // TODO(ahi): Init graphics
    
    // TODO(ahi): Init GUI
    
    // TODO(ahi): Init entity manager

    // TODO(ahi): Init game

    // TODO(ahi): Init editor

    log.infof("Hello from Untitled Horror Game! Current game version: %d.%d.%d",
                i32(game.config.version.major),
                i32(game.config.version.revision),
                i32(game.config.version.minor))

    // TEST TRIANGLE
    vertices := [?]f32 {
         0.5,  0.5, 0.0, 1.0, 0.0,
         0.5, -0.5, 0.0, 1.0, 1.0,
        -0.5, -0.5, 0.0, 0.0, 1.0,
        -0.5,  0.5, 0.0, 0.0, 0.0,
    }

    indices := [?]u32 {
        0, 1, 3,
        1, 2, 3,
    }

    shaders := shader_create_standard("gamedata/shaders/triangle_vtx.glsl", "gamedata/shaders/triangle_frg.glsl")
    defer shader_destroy(&shaders)

    layout := input_layout_init()
    defer input_layout_destroy(&layout)
    input_layout_bind(&layout)

    vbuffer := buffer_create(size_of(vertices), GpuBuffer_Type.VERTEX)
    defer buffer_free(&vbuffer)
    buffer_bind(&vbuffer)
    buffer_upload(&vbuffer, size_of(vertices), &vertices[0], 0)

    ibuffer := buffer_create(size_of(indices), GpuBuffer_Type.INDEX)
    defer buffer_free(&ibuffer)
    buffer_bind(&ibuffer)
    buffer_upload(&ibuffer, size_of(indices), &indices[0], 0)

    input_layout_push_element(0, 3, size_of(f32) * 5, 0, Input_Layout_Element.FLOAT);
    input_layout_push_element(1, 2, size_of(f32) * 5, size_of(f32) * 3, Input_Layout_Element.FLOAT);

    default_texture := engine_texture_load_simple("gamedata/assets/textures/test_texture.png")
    defer engine_texture_free(&default_texture);

    shader_texture := texture_init(0, 0, Texture_Format.RGBA8);
    defer texture_destroy(&shader_texture);

    texture_upload_shader_resource(&shader_texture, &default_texture);

    // Main loop
    loop: for {
        mouse_wheel_event := false

        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                    break loop
                case .MOUSEMOTION:
                    input_system_handle_mouse_delta(event.motion.xrel, event.motion.yrel)
                    input_system_handle_mouse_position(event.motion.x, event.motion.y)
                    break
                case .KEYDOWN:
                    input_system_handle_key(&event.key)
                    break
                case .KEYUP:
                    input_system_handle_key(&event.key)
                    break
                case .MOUSEBUTTONDOWN:
                    input_system_handle_button(&event.button)
                    break
                case .MOUSEBUTTONUP:
                    input_system_handle_button(&event.button)
                    break
                case .MOUSEWHEEL:
                    input_system_handle_wheel(event.wheel.x, event.wheel.y)
                    mouse_wheel_event = true
                    break
            }
        }
        if !mouse_wheel_event {
            input_system_handle_wheel(0, 0)
        }

        // Debug rectangle render
        context_clear()
        context_clear_color(0.3, 0.5, 0.8, 1.0)
        context_viewport(game.window.width, game.window.height)

        shader_bind(&shaders)
        input_layout_bind(&layout)
        buffer_bind(&vbuffer)
        buffer_bind(&ibuffer)
        texture_bind_shader_resource(&shader_texture, 0);

        context_draw_indexed(6)

        opengl_context_present(&game.gl_ctx)
    }
}
