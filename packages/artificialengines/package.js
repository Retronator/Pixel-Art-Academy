Package.describe({
  name: 'retronator:artificialengines',
  version: '1.0.0'
});

Npm.depends({
  twit: '2.2.9',
  stripe: '5.1.1',
  patreon: '0.3.0',
  'tumblr.js': '1.1.1',
  'path-to-regexp': '2.1.0'
});

Package.onUse(function(api) {
  var packages = [
    // Meteor
    'coffeescript',
    'spacebars',
    'stylus',
    'tracker',
    'mongo',
    'ddp-client',
    'random',
    'reactive-var',
    'reactive-dict',
    'check',
    'ejson',
    'markdown',
    'http',
    'oauth',
    'modules',

    // 3rd party
    'peerlibrary:assert',
    'peerlibrary:peerdb',
    'peerlibrary:peerdb-migrations',
    'peerlibrary:reactive-publish',
    'peerlibrary:blaze-components',
    'peerlibrary:blaze-common-component',
    'peerlibrary:reactive-field',
    'peerlibrary:computed-field',
    'peerlibrary:check-extension',
    'peerlibrary:server-autorun',
    'peerlibrary:directcollection',
    'limemakers:three',
    'okgrow:router-autoscroll',
    'stevezhu:lodash',
    'velocityjs:velocityjs',
    'meteorhacks:picker',
    'meteorhacks:inject-initial'
  ];

	api.use(packages);
  api.imply(packages);

  api.use('webapp', 'server');

  api.export('Artificial');

	api.addFile('artificial');

	// Global initialization
	api.addFile('everywhere/lodash/lodash');

	// Artificial Everywhere
  api.addFile('everywhere/everywhere');

  api.addClientFile('everywhere/jquery/positioncss');

  api.addFile('everywhere/three/color');
  api.addFile('everywhere/three/vectors');

  api.addFile('everywhere/lodash/lettercase');
  api.addFile('everywhere/lodash/nestedproperty');
  api.addFile('everywhere/lodash/urls');
  api.addFile('everywhere/lodash/math');
  api.addFile('everywhere/lodash/objects');
  api.addFile('everywhere/lodash/strings');

  api.addFile('everywhere/csvparser');
  api.addFile('everywhere/date');
  api.addFile('everywhere/datehelper');
  api.addFile('everywhere/daterange');
  api.addFile('everywhere/exceptions');
  api.addFile('everywhere/match');
  api.addFile('everywhere/reactivewrapper');
  api.addFile('everywhere/rectangle');

  // Artificial Control
  api.addFiles('control/control.coffee');

  api.addFiles('control/keyboard.coffee');
  api.addFiles('control/keyboardstate.coffee');
  api.addFiles('control/keys.coffee');

  // Artificial Mirage
  api.addFiles('mirage/mirage.coffee');

	api.addFiles('mirage/component.coffee');
	api.addFiles('mirage/csshelper.coffee');
  api.addFiles('mirage/datainput.coffee');
  api.addFiles('mirage/datainput.html');
	api.addFiles('mirage/debugfont.css');
  api.addFiles('mirage/debugfont.import.styl', 'client', {isImport:true});
	api.addFiles('mirage/display.html');
	api.addFiles('mirage/display.coffee');
	api.addFiles('mirage/display.styl');
  api.addFiles('mirage/helpers.import.styl', 'client', {isImport:true});
  api.addFiles('mirage/htmlhelper.coffee');
  api.addFiles('mirage/render.coffee');
  api.addFiles('mirage/render.html');
  api.addFiles('mirage/window.coffee', 'client');
  api.addUnstyledComponent('mirage/pixelimage');

  api.addFiles('mirage/markdown/markdown.coffee');
  api.addFiles('mirage/markdown/markdown.html');

  api.addFiles('mirage/spacebars/meteorhelpers.coffee');
  api.addFiles('mirage/spacebars/stringhelpers.coffee');
  api.addFiles('mirage/spacebars/numberhelpers.coffee');
  api.addFiles('mirage/spacebars/htmlhelpers.coffee');
  api.addFiles('mirage/spacebars/image.coffee');
  api.addFiles('mirage/spacebars/uncached.coffee');

  api.addFiles('mirage/mixins/autoresizetextarea.coffee');
  api.addFiles('mirage/mixins/autoselectinput.coffee');
  api.addFiles('mirage/mixins/persistentinput.coffee');

  api.addFiles('mirage/mixins/fullscreenscrolling/fullscreenscrolling.coffee');
  api.addFiles('mirage/mixins/fullscreenscrolling/fullscreenscrolling.styl');

  // Artificial Base
  // Depends on Artificial Mirage.
  api.addFile('base/base');

  api.addUnstyledComponent('base/app');

  api.addFile('base/method');
  api.addFile('base/subscription');

  api.addFile('base/router/router');
  api.addServerFile('base/router/router-server');
  api.addClientFile('base/router/router-client');
  api.addFile('base/router/route');
  api.addFile('base/router/spacebars');
  api.addUnstyledComponent('base/router/routelink');

  // Artificial Mummification
  api.addFile('mummification/mummification');

  api.addFile('mummification/mongohelper');
  api.addFile('mummification/document');
  api.addFile('mummification/persistentstorage');

  api.addFile('mummification/hierarchy/hierarchy');
  api.addFile('mummification/hierarchy/address');
  api.addFile('mummification/hierarchy/node');
  api.addFile('mummification/hierarchy/field');
  api.addFile('mummification/hierarchy/template');
  api.addFile('mummification/hierarchy/location');

  // Artificial Telepathy
  api.addFile('telepathy/telepathy');

  api.addFile('telepathy/emailcomposer');

  api.addServerFile('telepathy/twitter-server');
  api.addServerFile('telepathy/stripe-server');
  api.addServerFile('telepathy/patreon-server');
  api.addServerFile('telepathy/tumblr-server');

  // Artificial Babel
  api.addFile('babel/babel');
  api.addFile('babel/initialize');
  api.addFile('babel/helpers');

  api.addFile('babel/lodash/languageregion');

  api.addFile('babel/translation/translation');
  api.addServerFile('babel/translation/subscriptions');
  api.addFile('babel/translation/methods');
  api.addServerFile('babel/translation/migrations/0000-renamecollection');

  api.addFile('babel/language/language');
  api.addServerFile('babel/language/subscriptions');

  api.addFile('babel/region..');
  api.addFile('babel/region/lists');
  api.addServerFile('babel/region/subscriptions');

  api.addServerFile('babel/initialize-server/languages-data');
  api.addServerFile('babel/initialize-server/languages');
  api.addServerFile('babel/initialize-server/regions-data');
  api.addServerFile('babel/initialize-server/regions');

  api.addFile('babel/components..');
  api.addUnstyledComponent('babel/components/languageselection..');
  api.addUnstyledComponent('babel/components/translatable..');
  api.addComponent('babel/components/translation..');
  api.addFile('babel/components/regionselection..');
});
