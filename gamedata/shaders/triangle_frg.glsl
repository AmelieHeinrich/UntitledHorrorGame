//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 16/01/2024 16:16
//=============================================================================//

#version 450 core

in vec2 fragment_uvs;

out vec4 pixel_color;

uniform sampler2D diffuseTexture;

void main()
{
    pixel_color = texture(diffuseTexture, fragment_uvs);
}
