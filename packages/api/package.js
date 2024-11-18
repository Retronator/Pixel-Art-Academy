Package.describe({
  name: 'retronator:api',
  version: '1.0.0'
});

Package.registerBuildPlugin({
  name: 'glsl',
  sources: ['glslbuildplugin.js']
});

Package.onUse(function(api) {
  api.use('isobuild:compiler-plugin@1.0.0');

  expandPath = function(path) {
    parts = path.split('/');
    lastPart = parts[parts.length-1];
    dotsIndex = lastPart.indexOf('..');
    if (dotsIndex > 0 && dotsIndex == lastPart.length - 2) {
      lastPart = lastPart.substring(0, lastPart.length - 2);
      lastPart = lastPart + '/' + lastPart;
      parts[parts.length-1] = lastPart;
    }
    return parts.join('/');
  };

  // Extend API with helper functions.
  api.constructor.prototype.addFile = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".coffee");
  };
  api.constructor.prototype.addServerFile = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".coffee", ['server']);
  };
  api.constructor.prototype.addClientFile = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".coffee", ['client']);
  };
  api.constructor.prototype.addJavascript = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".js");
  };
  api.constructor.prototype.addServerJavascript = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".js", ['server']);
  };
  api.constructor.prototype.addClientJavascript = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".js", ['client']);
  };
  api.constructor.prototype.addHtml = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".html");
  };
  api.constructor.prototype.addStyle = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".styl");
  };
  api.constructor.prototype.addCss = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".css");
  };
  api.constructor.prototype.addStyledFile = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".styl"]);
  };
  api.constructor.prototype.addStyleImport = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".import.styl", ['client'], {isImport: true});
  };
  api.constructor.prototype.addComponent = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".html", path + ".styl"]);
  };
  api.constructor.prototype.addClientComponent = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".html", path + ".styl"], ['client']);
  };
  api.constructor.prototype.addUnstyledComponent = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".html"]);
  };
  api.constructor.prototype.addClientUnstyledComponent = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".html"], ['client']);
  };
  api.constructor.prototype.addThing = function(path, architecture) {
    path = expandPath(path);
    this.addFiles(path + ".coffee", architecture);
    this.addAssets(path + ".script", ['client', 'server']);
  };
  api.constructor.prototype.addThingComponent = function(path, architecture) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + ".html", path + ".styl"]);
    this.addAssets(path + ".script", ['client', 'server']);
  };
  api.constructor.prototype.addScript = function(path) {
    path = expandPath(path);
    this.addAssets(path + ".script", ['client', 'server']);
  };
  api.constructor.prototype.addData = function(path) {
    path = expandPath(path);
    this.addAssets(path + ".json", ['client', 'server']);
  };
  api.constructor.prototype.addServerData = function(path) {
    path = expandPath(path);
    this.addAssets(path + ".json", ['server']);
  };
  api.constructor.prototype.addFileWithData = function(path, architecture) {
    path = expandPath(path);
    this.addFiles(path + ".coffee", architecture);
    this.addAssets(path + ".json", ['client', 'server']);
  };
  api.constructor.prototype.addThingWithData = function(path, architecture) {
    path = expandPath(path);
    this.addFiles(path + ".coffee", architecture);
    this.addAssets(path + ".script", ['client', 'server']);
    this.addAssets(path + ".json", ['client', 'server']);
  };
  api.constructor.prototype.addGlsl = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".glsl", ['client']);
  };
  api.constructor.prototype.addFileWithGlsl = function(path) {
    path = expandPath(path);
    this.addFiles(path + ".coffee");
    this.addFiles(path + ".glsl", ['client']);
  };
  api.constructor.prototype.addMaterial = function(path) {
    path = expandPath(path);
    this.addFiles([path + ".coffee", path + "-vertex.glsl", path + "-fragment.glsl"], ['client']);
  };

});
