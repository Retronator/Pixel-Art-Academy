// LandsOfIllusions.Engine.Materials.unpackSampleReflectionParametersFragment

// Reflection parameters are stored in the green channel.
float reflectionParametersPacked = sample.g * 255.0;

reflectionParameters = vec3(
floor(reflectionParametersPacked / 16.0) / 16.0 * 0.3,
mod(floor(reflectionParametersPacked / 2.0), 8.0),
mod(reflectionParametersPacked, 2.0)
);
