// LandsOfIllusions.Engine.Materials.unpackSamplePaletteColorFragment

// Palette color (ramp and shade) is stored in the red channel.
float paletteColorPacked = mapSample.r * 255.0;
paletteColor = vec2(floor(paletteColorPacked / 16.0), mod(paletteColorPacked, 16.0));
paletteColor = (paletteColor + 0.5) / 256.0;
