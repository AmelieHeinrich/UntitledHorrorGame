//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 16/01/2024 15:13
//=============================================================================//

package duvet

import "core:log"

import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

OpenGL_Context :: struct {
    window: ^SDL.Window,
    gl_context: SDL.GLContext
}

OPENGL_MAJOR_VERSION :: 4
OPENGL_MINOR_VERSION :: 3

opengl_context_init :: proc(ctx: ^OpenGL_Context, win: ^SDL.Window, vsync: bool) {
    SDL.GL_SetAttribute(.CONTEXT_PROFILE_MASK, i32(SDL.GLprofile.CORE))
    SDL.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, OPENGL_MAJOR_VERSION)
    SDL.GL_SetAttribute(.CONTEXT_MINOR_VERSION, OPENGL_MINOR_VERSION)

    ctx.window = win
    ctx.gl_context = SDL.GL_CreateContext(win)
    if ctx.gl_context == nil {
        log.errorf("Failed to create OpenGL context!")
    }
    SDL.GL_MakeCurrent(ctx.window, ctx.gl_context)
    gl.load_up_to(OPENGL_MAJOR_VERSION, OPENGL_MINOR_VERSION, SDL.gl_set_proc_address)
    SDL.GL_SetSwapInterval(i32(vsync))

    log.debugf("Created OpenGL context of version %d.%d", OPENGL_MAJOR_VERSION, OPENGL_MINOR_VERSION)
}

opengl_context_present :: proc(ctx: ^OpenGL_Context) {
    SDL.GL_SwapWindow(ctx.window)
}

opengl_context_destroy :: proc(ctx: ^OpenGL_Context) {
    SDL.GL_DeleteContext(ctx.gl_context)
}
