PROCEDURAL PLANET: LAVENDER STAR-BOMB

°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

BY: Emiliya Al Yafei (alyafei)

°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RESOURCES:

Rendering Gas Giants using noise:
http://johnwhigham.blogspot.com/2011/11/gas-giants.html

Simplex noise:
https://github.com/ashima/webgl-noise

°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

BACKGROUND: 

I tried to make a planet akin to Jupiter. The main sphere reads in colors from an array of color vec3s (sampled from photos of lavender flowers :) ). Using simplex noise (a multi dimesnional version of perlin noise, also developed by Ken Perlin), I first add noise to the texture -- each fragment's color becomes the color at the position calculated from the product of the Simplex noise function and the fractal brownian noise function and the current position or normal. I also created Jupiter "eyes": this was done by taking the normal and getting a simplex noise value of some product of the normal, and then clamping the product of the various threshold values so that there wouldn't be any negative values. The "eyes" (which look like randomized blotches) occur where large bumps would have occured on the surface if it were done in a vertex shader (this was also how the comet effect was born!).

Although I definitely didn't want to mess with the surface after going through the effort getting it to work, I felt as though the planet itself looked quite bland. I added atmpospheric levels using larger spheres with various values of FMB and Simplex noise in order to get an animated cloud-like atmosphere. 

