/*
    image.frag
    Author: Samuel Vargas

    Fragment Shader for simple 2D images
*/

#version 330 core
in vec2 FragTex;
out vec4 FragColor;

uniform sampler2D image;

void main() {
    vec4 color = texture(image, FragTex);
    if (color.a < 0.1) discard;
    FragColor = color;
}