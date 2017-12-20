#version 330 core
out vec4 FragColor;

// TODO: Avoid hardcoding mapData
const uint ROWS = uint(9);
const uint COLS = uint(7);
uniform uint[int(ROWS * COLS)] mapData;
uniform vec2 player;

void main() {
    FragColor = vec4(gl_FragCoord.x, gl_FragCoord.y, mapData[0], 1.0f);
}