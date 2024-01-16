//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 16/01/2024 16:16
//=============================================================================//

#version 450 core

in vec3 fragment_color;

out vec4 pixel_color;

void main()
{
    pixel_color = vec4(fragment_color, 1.0);
}
