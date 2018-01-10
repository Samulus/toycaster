/*
    wall.frag
    Author: Samuel Vargas

*/

#version 330 core
out vec4 FragColor;

uniform uvec2 iResolution;
uniform sampler2D wallData;

float scale(float x, float inMin, float inMax, float outMin, float outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void main() {
    //uint xLoc = min(uint(gl_FragCoord.x), iResolution.x);
    uint xLoc = uint(gl_FragCoord.x);
    float yLoc = gl_FragCoord.y / iResolution.y  ;
    vec4 val = texelFetch(wallData, ivec2(xLoc, 0), 0);
    FragColor = vec4(val.r, yLoc, gl_FragCoord.x / iResolution.x, 1);
    /* Scale the input from [0 - 255] to 
    FragColor = vec4(val.rrr, 1.0);

    /*
        I
}