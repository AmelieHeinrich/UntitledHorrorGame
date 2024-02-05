//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package game

// Core imports
import "core:fmt"
import "core:log"
import "core:os"
import "core:encoding/json"
import "core:mem"
import "core:time"
import "core:math"
import "core:math/linalg"

// Vendor imports
import SDL "vendor:sdl2"

// Engine imports
import "render"
import "base"
import "asset"
import "audio"

MINOR_VERSION :: 1
REVISION :: 0
MAJOR_VERSION :: 0

Window_State :: struct {
    width: i32,
    height: i32,
    window: ^SDL.Window,
}

Config_Data :: struct {
    renderer: struct {
        vsync: bool,
        api: string
    },
    window: struct {
        type: string,
        width: f32,
        height: f32
    }
}

Game_State :: struct {
    config_file: base.Config_File,
    config: Config_Data,

    window: Window_State,
    gl_ctx: render.OpenGL_Context,
    events: base.Event_System,

    last_frame: time.Time,
    test: f32
}

game: Game_State

do_game :: proc() {
    // Init config file
    if !base.config_file_load(&game.config_file, "gamedata/game_settings.json") {
        log.error("Failed to load json settings file!")
        return
    }
    defer base.config_file_destroy(&game.config_file, "gamedata/game_settings.json")

    // Create window
    json.unmarshal(game.config_file.file_contents, &game.config)

    game.window.width = i32(game.config.window.width)
    game.window.height = i32(game.config.window.height)

    SDL.Init({.VIDEO})
    defer SDL.Quit()

    game.window.window = SDL.CreateWindow("Untitled Horror Game", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, game.window.width, game.window.height, {.OPENGL, .RESIZABLE})
    defer SDL.DestroyWindow(game.window.window)

    log.debugf("Created window Untitled Horror Game with dimensions (%d, %d)", game.window.width, game.window.height)

    // Init OpenGL Context
    render.opengl_context_init(&game.gl_ctx, game.window.window, game.config.renderer.vsync)
    defer render.opengl_context_destroy(&game.gl_ctx)

    // Init event system
    base.event_system_init(&game.events)
    defer base.event_system_free(&game.events)

    // Init input system
    base.input_system_init()
    defer base.input_system_free()

    // TODO(ahi): Init asset system

    // Init audio system
    audio.audio_system_init()
    defer audio.audio_system_destroy()
    
    // TODO(ahi): Init renderer
    scene_renderer := scene_renderer_init()
    defer scene_renderer_free(&scene_renderer)

    // TODO(ahi): Init GUI
    
    // TODO(ahi): Init entity manager

    // TODO(ahi): Init game

    // TODO(ahi): Init editor

    scene := scene_create()
    defer scene_free(&scene)

    helmet := scene_new_game_object(&scene)
    helmet.transform = linalg.matrix4_translate_f32({ -2.5, 0, 0 })
    game_object_init_render(helmet, "gamedata/assets/models/DamagedHelmet.gltf")

    suzanne := scene_new_game_object(&scene)
    suzanne.transform = linalg.matrix4_translate_f32({0, 0, 0})
    game_object_init_render(suzanne, "gamedata/assets/models/Suzanne.gltf")

    sci_fi_helmet := scene_new_game_object(&scene)
    sci_fi_helmet.transform = linalg.matrix4_translate_f32({2.5, 0, 0})
    game_object_init_render(sci_fi_helmet, "gamedata/assets/models/SciFiHelmet.gltf")

    log.infof("Hello from Untitled Horror Game! Current game version: %d.%d.%d",
                MAJOR_VERSION,
                REVISION,
                MINOR_VERSION)

    game.last_frame = time.now()

    // Main loop
    loop: for {
        t := time.now()
        dt: f32 = f32(t._nsec - game.last_frame._nsec) / 1000000000.0
        game.last_frame = t

        mouse_wheel_event := false
        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                    break loop
                case .MOUSEMOTION:
                    base.input_system_handle_mouse_delta(event.motion.xrel, event.motion.yrel)
                    base.input_system_handle_mouse_position(event.motion.x, event.motion.y)
                    break
                case .KEYDOWN:
                    base.input_system_handle_key(&event.key)
                    break
                case .KEYUP:
                    base.input_system_handle_key(&event.key)
                    break
                case .MOUSEBUTTONDOWN:
                    base.input_system_handle_button(&event.button)
                    break
                case .MOUSEBUTTONUP:
                    base.input_system_handle_button(&event.button)
                    break
                case .MOUSEWHEEL:
                    base.input_system_handle_wheel(event.wheel.x, event.wheel.y)
                    mouse_wheel_event = true
                    break
                case .WINDOWEVENT:
                    SDL.GetWindowSize(game.window.window, &game.window.width, &game.window.height)
                    break
            }
        }
        if !mouse_wheel_event {
            base.input_system_handle_wheel(0, 0)
        }
        
        scene_update(&scene, dt)

        render.context_clear()
        render.context_clear_color(0.0, 0.0, 0.0, 1.0)
        render.context_viewport(game.window.width, game.window.height)

        scene_renderer_render(&scene_renderer, &scene)

        render.opengl_context_present(&game.gl_ctx)
    }

    // Dump settings
    root := game.config_file.data.(json.Object)

    window := root["window"].(json.Object)
    window["width"] = json.Float(f32(game.window.width))
    window["height"] = json.Float(f32(game.window.height))
}
