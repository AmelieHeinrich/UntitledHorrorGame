//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 16/01/2024 16:15
//=============================================================================//

#version 450 core

layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_normals;
layout(location = 2) in vec2 vertex_uvs;

out vec2 fragment_uvs;
out vec3 fragment_normals;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
    fragment_uvs = vertex_uvs;
    fragment_normals = vertex_normals;
    gl_Position = proj * view * model * vec4(vertex_position, 1.0);
}