/*
    wall.frag
    Author: Samuel Vargas
*/

#version 330 core
out vec4 FragColor;

uniform uvec2 iResolution;
uniform sampler2D wallData;

void main() {
    uint xLoc = uint(gl_FragCoord.x);
    float wallHeight = texelFetch(wallData, ivec2(xLoc, 0), 0).r;

    float heightNormalized = gl_FragCoord.y / iResolution.y;

    // Calculate minimum and maximum pixels to paint within
    float middle = 0.5f;
    float offset = (middle * (wallHeight ));
    float minimum = middle - offset; // 1.0f at the least
    float maximum = middle + offset; // 0.0f at the most

    if (heightNormalized >= minimum && heightNormalized <= maximum) {
        FragColor = vec4(1,1,1,1);
    } else {
        FragColor = vec4(gl_FragCoord.xy / iResolution.xy, 0, 1);
    }
}
