Package.describe({
  name: 'retronator:blaze-components',
  version: '0.23.0'
});

// Based on meteor/packages/templating/package.js.
Package.registerBuildPlugin({
  name: "compileBlazeComponentsTemplatesBatch",
  use: [
    'caching-html-compiler@1.1.2',
    'ecmascript@0.8.2',
    'templating-tools@1.1.2',
    'spacebars-compiler@1.1.2',
    'html-tools@1.0.11'
  ],
  sources: [
    'patch-compiling.js',
    'compile-templates.js'
  ]
});

Package.onUse(function (api) {
  // Core dependencies.
  api.use([
    'blaze',
    'coffeescript',
    'underscore',
    'tracker',
    'reactive-var',
    'ejson',
    'spacebars',
    'jquery',
    'tracker'
  ]);

  api.use([
    'templating',
    'peerlibrary:user-extra@0.3.0'
  ], {weak: true});
  
  api.use([
    'peerlibrary:assert',
    'peerlibrary:reactive-field',
    'peerlibrary:computed-field',
    'peerlibrary:data-lookup',
    'peerlibrary:assert',
    'momentjs:moment@2.20.1',
    'isobuild:compiler-plugin@1.0.0'
  ]);

  api.imply([
    'meteor',
    'blaze',
    'spacebars'
  ]);

  api.export('Template');
  api.export('BlazeComponent');
  api.export('CommonComponent');
  api.export('CommonMixin');
  api.export('BaseComponent');
  
  api.addFiles([
    'template.coffee',
    'compatibility/templating.js',
    'compatibility/dynamic.html',
    'compatibility/dynamic.js',
    'compatibility/lookup.js',
    'compatibility/attrs.js',
    'compatibility/materializer.js',
    'basecomponent.coffee',
    'lib.coffee',
    'base.coffee',
    'component.coffee',
    'mixin.coffee'
  ]);

  api.addFiles([
    'client.coffee'
  ], 'client');

  api.addFiles([
    'server.coffee'
  ], 'server');
});
