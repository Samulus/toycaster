/*
    wall.frag
    Author: Samuel Vargas
*/

#version 330 core
out vec4 FragColor;

uniform uvec2 iResolution;
uniform sampler2D wallData;
uniform sampler2D wallColor;

void main() {
    uint xLoc = uint(gl_FragCoord.x);
    float height = texelFetch(wallData, ivec2(xLoc, 0), 0).r;
    int color = int(texelFetch(wallColor, ivec2(xLoc, 0), 0).r);

    float heightNormalized = gl_FragCoord.y / iResolution.y;
    float ratio = height / iResolution.y;

    // Debug: Green Walls If missing
    if (ratio <= 0.1) {
        heightNormalized = 0.5;
    }

    // Calculate Minimum and Maximum Locations to Place Pixel Within
    float middle = 0.5f;
    float offset = (middle * ratio);
    float minimum = middle - offset; // 1.0f at the least
    float maximum = middle + offset; // 0.0f at the most


    // ratio > 0.1 prevents tiny thin wall strips from far away / non existent
    // walls from being rendered
    if (ratio > 0.1 && heightNormalized >= minimum && heightNormalized <= maximum) {
        /*
        if (ratio <= 0.1) {
            FragColor = vec4(heightNormalized, iResolution.x / iResolution.y, heightNormalized, 1);
        }
        */

        if (color == 1) { // Red is a vertical wall
            FragColor = vec4(1, heightNormalized, heightNormalized, 1);
        }
        else { // Blue is a horizontal wall
            FragColor = vec4(heightNormalized, heightNormalized, 1, 1);
        }
    } else {
        FragColor = vec4(gl_FragCoord.xy / iResolution.xy, 0, 1);
    }
}
