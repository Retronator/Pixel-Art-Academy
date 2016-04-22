// pico-8 web player variables that must be present
var playable_area_count = 0;
var playarea_state = 0;
var codo_command = 0;
var codo_command_p = 0;
var codo_volume = 256;
var codo_running = true;
var pa_pid = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Pico-8 buttons to Web Player key codes lookup table
var pico8keys = [
  [37, 39, 38, 40, 90, 88],
  [83, 70, 69, 68, 9, 81]
];

Pico = {};
window.Pico = Pico;

// Loads pico8 web player library and setups everything to run
Pico.load = function (element, cart) {
  // create canvas and add it into element
  var canvas = document.createElement('canvas');
  element.appendChild(canvas);

  // setup module to load card and point to our canvas
  Pico.Module = {
    arguments: [cart],
    canvas: canvas
  };

  // load pico8 library
  var head = document.getElementsByTagName('head')[0];
  var js = document.createElement('script');
  js.src = '/packages/pico8/pico8.min.js';
  head.appendChild(js);
};

// press button
Pico.press = function (k, p) {
  var kc = pico8keys[p][k];
  Pico._press({type: 'keydown', keyCode: kc});
};

// release button
Pico.release = function (k, p) {
  var kc = pico8keys[p][k];
  Pico._press({type: 'keyup', keyCode: kc});
};

// set volume (0 - 256)
Pico.volume = function (vol) {
  codo_volume = vol;
  codo_command = 2;
  codo_command_p = codo_volume;
};

// toggle sound
Pico.mute = function () {
  codo_volume = (codo_volume == 0 ? 256 : 0);
  codo_command = 2;
  codo_command_p = codo_volume;
};

// toggle pause
Pico.pause = function () {
  codo_running = !codo_running;
  if (codo_running) {
    Pico.Module.resumeMainLoop();
  } else {
    Pico.Module.pauseMainLoop();
  }
};

// reset cart
Pico.reset = function () {
  codo_command = 1;
  codo_running = true;
  Pico.Module.resumeMainLoop();
};
