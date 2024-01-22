//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Untitled Horror Game
// $Create Time: 22/01/2024 19:22
//=============================================================================//

package render

import gl "vendor:OpenGL"

context_clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

context_clear_color :: proc(r: f32, g: f32, b: f32, a: f32) {
    gl.ClearColor(r, g, b, a)
}

context_viewport :: proc(width: i32, height: i32, x: i32 = 0, y: i32 = 0) {
    gl.Viewport(x, y, width, height)
}

context_draw :: proc(start: i32, count: i32) {
    gl.DrawArrays(gl.TRIANGLES, start, count)
}

context_draw_indexed :: proc(count: i32) {
    gl.DrawElements(gl.TRIANGLES, count, gl.UNSIGNED_INT, nil)
}
