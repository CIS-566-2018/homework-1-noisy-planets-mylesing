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

// color palette
const vec3 planetCol[18] = vec3[](vec3(0.62, 0.66, 0.98),
                                vec3(0.62, 0.66, 0.98),
                                vec3(0.62, 0.66, 0.98),
                                vec3(0.72, 0.82, 0.99),
                                vec3(0.51, 0.51, 0.77),
                                vec3(0.51, 0.51, 0.77),
                                vec3(0.76, 0.70, 0.95),
                                vec3(0.69, 0.55, 0.78),
                                vec3(0.74, 0.55, 0.79),
                                vec3(0.74, 0.55, 0.79),
                                vec3(0.79, 0.70, 0.88),
                                vec3(0.70, 0.65, 0.85),
                                vec3(0.60, 0.57, 0.84),
                                vec3(0.77, 0.80, 0.95),
                                vec3(0.77, 0.80, 0.95),
                                vec3(0.76, 0.77, 0.96),
                                vec3(0.84, 0.76, 0.98),
                                vec3(0.79, 0.85, 0.99));

const vec3 a = vec3(0.4, 0.5, 0.8);
const vec3 b = vec3(0.2, 0.4, 0.2);
const vec3 c = vec3(1.0, 1.0, 2.0);
const vec3 d = vec3(0.25, 0.25, 0.0);

const vec3 e = vec3(0.2, 0.5, 0.8);
const vec3 f = vec3(0.2, 0.25, 0.5);
const vec3 g = vec3(1.0, 1.0, 0.1);
const vec3 h = vec3(0.0, 0.8, 0.2);

// SIMPLEX NOISE CREDIT:
// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  { 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
  }

// fractal noise function
float noise(vec3 position, int octaves, float frequency, float persistence) {
    float total = 0.0; // total value
    float maxAmplitude = 0.0; // highest theoretical amplitude
    float amplitude = 1.0;
    for (int i = 0; i < octaves; i++) {

        // Get the noise sample
        total += snoise(position * frequency) * amplitude;

        // Make the wavelength twice as small
        frequency *= 2.0;

        // Add to our maximum possible amplitude
        maxAmplitude += amplitude;

        // Reduce amplitude according to persistence for the next octave
        amplitude *= persistence;
    }

    // Scale the result by the maximum amplitude
    return total / maxAmplitude;
}

void main() {
        // eye of jupiter
        // get a set point on the sphere:
        vec3 eyeCenter = vec3(1, 0, 0);
        float radius = 0.2;
        float dFromCenter = distance(fs_Pos.xyz, eyeCenter);
        if (dFromCenter < radius) {
          //fs_Pos = rotate(fs_Pos, dFromCenter * 5.0, fs_Nor);
        }

        // three threshold samples for warp-locations on planet
        float t1 = snoise((fs_Nor.xyz + 1000.0) * 2.0) - 0.3;
        float t2 = snoise((fs_Nor.xyz + 800.0) * 2.0) - 0.5;
        float t3 = snoise((fs_Nor.xyz + 1600.0) * 2.0) - 0.6;

        // get overall threshold -- make sure it's not negative !
        float threshold = max(t1 * t2 * t3, 0.0);

        // generate noisy gradient with animation, sampling from color gradient
        float n1 = noise(fs_Nor.xyz * 20.0 + 0.05 * mod(u_Time, 2000.0), 6, 0.1, 0.8);
        float n2 = noise(fs_Nor.xyz, 5, 5.8, 0.75) * 0.015 - 0.01;
        float n = n1 + n2;

        // get color array value for gas giant color map
        float coord = ((18.0 - abs(fs_Pos.y) * 18.0) + n + threshold * 10.0);
        int val3 = int(coord);

        // look up the texture
        vec3 texColor = planetCol[val3];       

        // blue spots for debugging
        //#define DEBUG
        #ifdef DEBUG
        texColor += vec3(0.0, 0.0, threshold * 3.0);
        #endif

        // dark side: lambert shader// Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = min(diffuseTerm, 1.0);
        diffuseTerm = max(diffuseTerm, 0.0);

        float ambientTerm = 0.4;

        float lightIntensity = diffuseTerm + ambientTerm;

        // Compute final shaded color
        out_Col = vec4(texColor * (lightIntensity - vec3(0.25, 0.25, 0.0)), 1.0);
}
