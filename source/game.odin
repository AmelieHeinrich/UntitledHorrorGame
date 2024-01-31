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

    // TODO(ahi): Init input
    base.input_system_init()
    defer base.input_system_free()

    // TODO(ahi): Init asset system

    // TODO(ahi): Init audio
    
    // TODO(ahi): Init graphics
    
    // TODO(ahi): Init GUI
    
    // TODO(ahi): Init entity manager

    // TODO(ahi): Init game

    // TODO(ahi): Init editor

    // MODEL LOADER CHECK
    model := asset.engine_model_load("gamedata/assets/models/DamagedHelmet.gltf")
    defer asset.engine_model_free(&model)

    // Make camera
    camera := free_cam_init()

    // Make game shaders
    shaders := render.shader_create_standard("gamedata/shaders/geometry_vtx.glsl", "gamedata/shaders/geometry_frg.glsl")
    defer render.shader_destroy(&shaders)

    // Rando ass texture
    texture := asset.engine_texture_load_simple("gamedata/assets/textures/Default_albedo.png")
    
    gpu_texture := render.texture_init(i32(texture.handle.width), i32(texture.handle.height), render.Texture_Format.RGBA8)
    defer render.texture_destroy(&gpu_texture)
    render.texture_upload_shader_resource(&gpu_texture, i32(texture.handle.width), i32(texture.handle.height), &texture.handle.pixels)

    asset.engine_texture_free(&texture)

    // VAO, VBO and EBO for testing
    input_layout := render.input_layout_init()
    render.input_layout_bind(&input_layout)

    vertex_buffer := render.buffer_create(len(model.meshes[0].vertices) * size_of(f32) * 8, render.GpuBuffer_Type.VERTEX)
    defer render.buffer_free(&vertex_buffer)
    render.buffer_bind(&vertex_buffer)
    render.buffer_upload(&vertex_buffer, len(model.meshes[0].vertices) * size_of(f32) * 8, &model.meshes[0].vertices[0], 0)

    index_buffer := render.buffer_create(len(model.meshes[0].indices) * size_of(u32), render.GpuBuffer_Type.INDEX)
    defer render.buffer_free(&index_buffer)
    render.buffer_bind(&index_buffer)
    render.buffer_upload(&index_buffer, len(model.meshes[0].indices) * size_of(u32), &model.meshes[0].indices[0], 0)

    render.input_layout_push_element(0, 3, size_of(asset.Gltf_Vertex), 0, render.Input_Layout_Element.FLOAT)
    render.input_layout_push_element(1, 3, size_of(asset.Gltf_Vertex), size_of(f32) * 3, render.Input_Layout_Element.FLOAT)
    render.input_layout_push_element(2, 2, size_of(asset.Gltf_Vertex), size_of(f32) * 6, render.Input_Layout_Element.FLOAT)

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

        free_cam_input(&camera, dt)
        free_cam_update(&camera, dt)
        
        render.context_clear()
        render.context_clear_color(0.0, 0.0, 0.0, 1.0)
        render.context_viewport(game.window.width, game.window.height)
        render.shader_bind(&shaders)
        render.input_layout_bind(&input_layout)
        render.buffer_bind(&vertex_buffer)
        render.buffer_bind(&index_buffer)
        render.texture_bind_shader_resource(&gpu_texture, 0)
        render.shader_uniform_mat4(&shaders, "proj", &camera.projection[0][0])
        render.shader_uniform_mat4(&shaders, "view", &camera.view[0][0])
        render.shader_uniform_mat4(&shaders, "model", &model.meshes[0].transformation_matrix[0][0])
        render.context_draw_indexed(i32(len(model.meshes[0].indices)))

        render.opengl_context_present(&game.gl_ctx)
    }

    // Dump settings
    root := game.config_file.data.(json.Object)

    window := root["window"].(json.Object)
    window["width"] = json.Float(f32(game.window.width))
    window["height"] = json.Float(f32(game.window.height))
}
