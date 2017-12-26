/*
    wall.frag
    Author: Samuel Vargas

*/

#version 330 core
out vec4 FragColor;

uniform uvec2 iResolution;
uniform sampler2D wallData;

void main() {
    //uint xLoc = min(uint(gl_FragCoord.x), iResolution.x);
    uint xLoc = uint(gl_FragCoord.x);
    vec4 val = texelFetch(wallData, ivec2(xLoc, 0), 0);
    FragColor=vec4(val.rr, gl_FragCoord.x / iResolution.x, 1);
}