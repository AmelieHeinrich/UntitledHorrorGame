//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 16/01/2024 16:15
//=============================================================================//

#version 450 core

layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec2 vertex_uvs;

out vec2 fragment_uvs;

void main() {
    fragment_uvs = vertex_uvs;
    gl_Position = vec4(vertex_position, 1.0);
}
