/*
    image.vert
    Author: Samuel Vargas

    Vertex Shader for simple 2D images
*/

#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTex;

uniform mat4 transform;

out vec2 FragTex;

void main() {
    gl_Position = transform * vec4(aPos.x, aPos.y, aPos.z, 1.0);
    FragTex = aTex;
}