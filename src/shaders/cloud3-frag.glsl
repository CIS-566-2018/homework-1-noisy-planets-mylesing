#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time; // timer update

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 new_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed

void main() {

        // rainbow filter : changes color with variation of time
        vec3 rainbow = vec3((u_Color.x + abs(new_Pos.x - fs_Pos.x) * abs(sin(u_Time * 0.05)) * 2.0), 
                            (u_Color.y + abs(new_Pos.y - fs_Pos.y) * abs(sin(u_Time * 0.05)) * 2.0), 
                            (u_Color.z + abs(new_Pos.z - fs_Pos.z) * abs(cos(u_Time * 0.06) * 2.0)));

        // multiply over the color of the original texture

        float dist = distance(new_Pos, fs_Pos) * 0.75;

        vec3 skyCol = vec3(1.0, 2.0 * dist, 2.0 * dist);
        vec3 color = skyCol + rainbow;

        // Compute final shaded color
        out_Col = vec4(color, dist);
}