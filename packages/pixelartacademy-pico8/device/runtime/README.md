# PICO-8 Runtime

PICO-8 by Lexaloffle Games LLP. Runtime (pico8.min.js) provided with permission from the author. Not covered by AGPL.

The runtime has been modified to:

- Store audio context on Module so that we can close it after exiting.
- Forward general purpose input output (GPIO) calls to Module.gpio function.
