Plugin.registerCompiler({
  extensions: ['glsl'],
  filenames: []
}, () => new GLSLCompiler);

class GLSLCompiler {
  processFilesForTarget(files) {
    files.forEach((file) => {
      var glslSource = file.getContentsAsString();

      // Get the variable into which to store the GLSL source code from the comment on the first line.
      var newLineLocation = glslSource.indexOf('\n');
      var glslSourceVariable = glslSource.substring(3, newLineLocation);

      // Create the javascript source that assigns the GLSL source to the target variable.
      var javaScriptSource = 'THREE.ShaderChunk["' + glslSourceVariable + '"] = `' + glslSource + '`;';

      file.addJavaScript({
        data: javaScriptSource,
        path: `${file.getPathInPackage()}-glsl.js`
      });
    });
  }
}
