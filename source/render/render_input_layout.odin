//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Untitled Horror Game
// $Create Time: 22/01/2024 19:27
//=============================================================================//

package render

import gl "vendor:OpenGL"

Input_Layout_Element :: enum {
    FLOAT,
    INT
}

Input_Layout :: struct {
    id: u32
}

input_element_to_gl :: proc(element: Input_Layout_Element) -> u32 {
    switch element {
        case .FLOAT:
            return gl.FLOAT
        case .INT:
            return gl.INT
    }
    return gl.FLOAT
}

input_layout_init :: proc() -> Input_Layout {
    layout: Input_Layout
    gl.GenVertexArrays(1, &layout.id)
    return layout
}

input_layout_destroy :: proc(layout: ^Input_Layout) {
    gl.DeleteVertexArrays(1, &layout.id)
}

input_layout_bind :: proc(layout: ^Input_Layout) {
    gl.BindVertexArray(layout.id)
}

input_layout_unbind :: proc() {
    gl.BindVertexArray(0)
}

input_layout_push_element :: proc(index: u32, attribute_size: i32, stride: i32, offset: uintptr, attribute_type: Input_Layout_Element) {
    gl.EnableVertexAttribArray(index)
    gl.VertexAttribPointer(index, attribute_size, input_element_to_gl(attribute_type), gl.FALSE, stride, offset)
}
