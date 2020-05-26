// THREE
// HACK: We create this file because common is a reserved keyword in GLSL and we don't want reserved keyword appearing
// in our GLSL files, even in the #include statements, since that creates a syntax error in the IDE highlighter. Instead
// we include this file, which is marked as a plain text file and will not produce an error.
#include <common>
