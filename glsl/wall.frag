#version 330 core
out vec4 FragColor;

const int MaximumColumns = 16;
uniform uint[MaximumColumns] walls;

void main() {
    float x = gl_FragCoord.x;

    if (x < MaximumColumns) {
        float v = walls[int(x)];
        FragColor = vec4(v, v, v, 1);
    } else {
        FragColor = vec4(1, 0, 0, 1);
    }
}
