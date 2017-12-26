/*
    wall.frag
    Author: Samuel Vargas

    wallData - Really long 1D texture that is guaranteed to be
    be either min(gameWindow.width, MaximumScreenWidth)
*/

#version 330 core
out vec4 FragColor;

uniform uvec2 iResolution;
uniform sampler2D wallData;

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    FragColor = vec4(uv, 0, 1);
}
