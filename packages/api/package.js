Package.describe({
  name: 'retronator:api',
  version: '1.0.0'
});

Package.onUse(function(api) {
  // Extend API with helper functions.
  api.constructor.prototype.addFile = function(path) {
    this.addFiles(path + ".coffee");
  };
  api.constructor.prototype.addServerFile = function(path) {
    this.addFiles(path + ".coffee", ['server']);
  };
  api.constructor.prototype.addClientFile = function(path) {
    this.addFiles(path + ".coffee", ['client']);
  };
  api.constructor.prototype.addHtml = function(path) {
    this.addFiles(path + ".html");
  };
  api.constructor.prototype.addStyle = function(path) {
    this.addFiles(path + ".styl");
  };
  api.constructor.prototype.addStyledFile = function(path) {
    this.addFiles([path + ".coffee", path + ".styl"]);
  };
  api.constructor.prototype.addStyleImport = function(path) {
    this.addFiles(path + ".import.styl", ['client'], {isImport: true});
  };
  api.constructor.prototype.addComponent = function(path) {
    this.addFiles([path + ".coffee", path + ".html", path + ".styl"]);
  };
  api.constructor.prototype.addUnstyledComponent = function(path) {
    this.addFiles([path + ".coffee", path + ".html"]);
  };
  api.constructor.prototype.addThing = function(path, architecture) {
    this.addFiles(path + ".coffee", architecture);
    this.addAssets(path + ".script", ['client', 'server']);
  };
  api.constructor.prototype.addThingComponent = function(path, architecture) {
    this.addFiles([path + ".coffee", path + ".html", path + ".styl"]);
    this.addAssets(path + ".script", ['client', 'server']);
  };
  api.constructor.prototype.addScript = function(path) {
    this.addAssets(path + ".script", ['client', 'server']);
  };
});
