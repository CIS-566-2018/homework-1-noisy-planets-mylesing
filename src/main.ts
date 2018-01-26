import {vec3, vec4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Drawable from './geometry/Icosphere';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentiall
  // color parameter
  color: [125, 0, 0, 1.0], // RGBA values
  shader: 'planet',
  shape: 'icosphere',
  atmosphereLVL: 0,
  cometMode: false,
  skySpeed: 1.0,
};

let icosphere: Icosphere;
let skysphere1: Icosphere; // atmosphere level 
let skysphere2: Icosphere; // atmosphere level 
let skysphere3: Icosphere; // atmosphere level 
let square: Square;
let cube: Cube;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  skysphere1 = new Icosphere(vec3.fromValues(0, 0, 0), 1.2, controls.tesselations);
  skysphere1.create();
  skysphere2 = new Icosphere(vec3.fromValues(0, 0, 0), 1.5, controls.tesselations);
  skysphere2.create();
  skysphere3 = new Icosphere(vec3.fromValues(0, 0, 0), 2.0, controls.tesselations);
  skysphere3.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
}

let time: number;
time = 0;

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  // adding color control to GUI
  gui.addColor(controls, 'color');
  // gui
  gui.add(controls, 'shader', ['lambert', 'funky bounce', 'planet']);
  gui.add(controls, 'shape', ['icosphere', 'cube', 'square']);
  gui.add(controls, 'atmosphereLVL', [0, 1, 2, 3]);
  gui.add(controls, 'cometMode');
  gui.add(controls, 'skySpeed', [0.05, 0.5, 1.0, 1.5, 2.0]);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);


  // store current color
  let currCol: vec4;

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);

    let shader: ShaderProgram;
    if (controls.shader == 'lambert') {
    shader = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
    ]);
    } else if (controls.shader == 'funky bounce') {
    shader = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/newshader-vert.glsl')),
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/newshader-frag.glsl')),
    ]);
    } else {
      shader = new ShaderProgram([
        new Shader(gl.VERTEX_SHADER, require('./shaders/planet-vert.glsl')),
        new Shader(gl.FRAGMENT_SHADER, require('./shaders/planet-frag.glsl')),
      ]);

    }

    // atmospheric clouds shader
    let skyShader: ShaderProgram;
    if (!controls.cometMode) {
      skyShader = new ShaderProgram([
        new Shader(gl.VERTEX_SHADER, require('./shaders/cloud-vert.glsl')),
        new Shader(gl.FRAGMENT_SHADER, require('./shaders/cloud-frag.glsl')),
      ]);
    } else {
      skyShader = new ShaderProgram([
        new Shader(gl.VERTEX_SHADER, require('./shaders/comet-vert.glsl')),
        new Shader(gl.FRAGMENT_SHADER, require('./shaders/comet-frag.glsl')),
      ]);
    }

    let skyShader1: ShaderProgram;
    skyShader1 = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/cloud2-vert.glsl')),
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/cloud2-frag.glsl')),
    ]);

    let skyShader2: ShaderProgram;
    skyShader2 = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/cloud3-vert.glsl')),
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/cloud3-frag.glsl')),
    ]);
    

    renderer.clear();
    // set time
    shader.setTime(time);
    skyShader.setTime(time * controls.skySpeed);
    skyShader1.setTime(time * controls.skySpeed);
    skyShader2.setTime(time * controls.skySpeed);
    time++;

    // set color 
    currCol = vec4.fromValues(controls.color[0] / 255.0, controls.color[1] / 255.0, controls.color[2] / 255.0, 1.0);
    shader.setGeometryColor(currCol);
    skyShader.setGeometryColor(currCol);
    skyShader1.setGeometryColor(currCol);
    skyShader2.setGeometryColor(currCol);

    // render
    if (controls.shape == 'icosphere') {
      renderer.render(camera, shader, [
        icosphere,
      ]);
    } else if (controls.shape == 'cube') {
      renderer.render(camera, shader, [
        cube,
      ]);
    } else {
      renderer.render(camera, shader, [
        square,
      ]);
    }

    // opacity for clouds
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    gl.enable(gl.BLEND);
    //gl.disable(gl.DEPTH_TEST);

    if (controls.atmosphereLVL >= 1) {
      renderer.render(camera, skyShader, [
        skysphere1,
      ]);
    }

    if (controls.atmosphereLVL >= 2) {
      if (controls.cometMode) {
        renderer.render(camera, skyShader, [
          skysphere2,
        ]);
      } else {
        renderer.render(camera, skyShader1, [
          skysphere2,
        ]);
      }
    }

    if (controls.atmosphereLVL >= 3) {
      if (controls.cometMode) {
        renderer.render(camera, skyShader, [
          skysphere3,
        ]);
      } else {
        renderer.render(camera, skyShader2, [
          skysphere3,
        ]);
      }
      
    }

    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
