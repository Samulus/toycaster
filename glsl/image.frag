/*
    image.frag
    Author: Samuel Vargas

    Fragment Shader for simple 2D images
*/

#version 330 core
in vec2 FragTex;
out vec4 FragColor;

uniform sampler2D minimapImage;

void main() {
    FragColor = texture(minimapImage, FragTex);
}