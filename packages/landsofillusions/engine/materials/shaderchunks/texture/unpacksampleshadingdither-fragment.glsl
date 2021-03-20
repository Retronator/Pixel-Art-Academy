// LandsOfIllusions.Engine.Materials.unpackSampleShadingDitherFragment

// Dither is stored in the blue channel.
float ditherParameterPacked = mapSample.b * 255.0;

shadingDither = floor(ditherParameterPacked / 32.0) / 8.0;
