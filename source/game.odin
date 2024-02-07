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
import "imgui"
import "imgui/imgui_impl_opengl3"
import "imgui/imgui_impl_sdl2"

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
    test: f32,

    editor_focused: b32
}

game: Game_State

do_game :: proc() {
    // Init config file
    if !base.config_file_load(&game.config_file, "gamedata/game_settings.json") {
        log.error("Failed to load json settings file!")
        return
    }

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
    
    // Init ImGui
    imgui.CHECKVERSION()
    imgui.CreateContext(nil)
    io := imgui.GetIO()
    io.ConfigFlags += {.NavEnableKeyboard, .NavEnableGamepad}
	when imgui.IMGUI_BRANCH == "docking" {
		io.ConfigFlags += {.DockingEnable}
		io.ConfigFlags += {.ViewportsEnable}

		style := imgui.GetStyle()
		style.WindowRounding = 0
		style.Colors[imgui.Col.WindowBg].w =1
	}
	imgui.StyleColorsDark(nil)
    imgui_impl_sdl2.InitForOpenGL(game.window.window, game.gl_ctx.gl_context)
	imgui_impl_opengl3.Init(nil)

    // Init renderer
    scene_renderer := scene_renderer_init()
    defer scene_renderer_free(&scene_renderer)
    
    // Init entity manager
    scene := scene_deserialize("gamedata/scenes/test_scene.json")
    defer scene_free(&scene)

    // TODO(ahi): Init game

    // Init editor
    scene_editor_init()

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
            imgui_impl_sdl2.ProcessEvent(&event)
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

        scene_process_reload(&scene);
        scene_editor_clean()
        
        scene_update(&scene, dt, !game.editor_focused)

        render.context_clear()
        render.context_clear_color(0.0, 0.0, 0.0, 1.0)
        render.context_viewport(game.window.width, game.window.height)

        scene_renderer_render(&scene_renderer, &scene)

        imgui_impl_opengl3.NewFrame()
        imgui_impl_sdl2.NewFrame()
        imgui.NewFrame()

        scene_editor_render(&scene, &game.editor_focused)

        io := imgui.GetIO()
        imgui.Render()
        imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())
        when imgui.IMGUI_BRANCH == "docking" {
            backup_current_window := SDL.GL_GetCurrentWindow()
            backup_current_context := SDL.GL_GetCurrentContext()
            imgui.UpdatePlatformWindows()
            imgui.RenderPlatformWindowsDefault()
            SDL.GL_MakeCurrent(backup_current_window, backup_current_context);
        }

        render.opengl_context_present(&game.gl_ctx)
    }

    // Dump settings
    root := game.config_file.data.(json.Object)

    window := root["window"].(json.Object)
    window["width"] = json.Float(f32(game.window.width))
    window["height"] = json.Float(f32(game.window.height))

    base.config_file_destroy(&game.config_file, "gamedata/game_settings.json")
    scene_serialize(&scene, "gamedata/scenes/test_scene.json")

    delete(game.config.window.type)
    delete(game.config.renderer.api)
}
