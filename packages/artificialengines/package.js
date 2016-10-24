Package.describe({
  name: 'retronator:artificialengines',
  version: '1.0.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2.0.2');

  packages = [
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

    // 3rd party
    'peerlibrary:assert@0.2.5',
    'peerlibrary:peerdb@0.20.0',
    'peerlibrary:peerdb-migrations@0.2.1',
    'peerlibrary:reactive-publish@0.3.0',
    'peerlibrary:blaze-components@0.19.0',
    'peerlibrary:blaze-common-component@0.2.0',
    'peerlibrary:blaze-layout-component@0.1.1',
    'peerlibrary:reactive-field@0.1.0',
    'peerlibrary:computed-field@0.3.1',
    'peerlibrary:check-extension@0.1.1',
    'peerlibrary:server-autorun@0.5.2',
    'limemakers:three@0.75.0',
    'mrt:underscore-string-latest@2.3.3',
	  'kadira:flow-router',
    'kadira:blaze-layout',
	  'okgrow:router-autoscroll',
	  'stevezhu:lodash@4.16.4',
    'velocityjs:velocityjs@1.2.1'
  ];

	api.use(packages);
  api.imply(packages);

  api.export('Artificial');

	api.addFiles('artificial.coffee');

	// Global initialization
	api.addFiles('everywhere/lodash/lodash.coffee');

	// Artificial Everywhere
  api.addFiles('everywhere/everywhere.coffee');

  api.addFiles('everywhere/jquery/positioncss.coffee', 'client');

  api.addFiles('everywhere/three/color.coffee');

  api.addFiles('everywhere/lodash/lettercase.coffee');
  api.addFiles('everywhere/lodash/nestedproperty.coffee');
  api.addFiles('everywhere/lodash/urls.coffee');
  api.addFiles('everywhere/lodash/math.coffee');

  api.addFiles('everywhere/date.coffee');
  api.addFiles('everywhere/datehelper.coffee');
  api.addFiles('everywhere/daterange.coffee');
  api.addFiles('everywhere/exceptions.coffee');
  api.addFiles('everywhere/match.coffee');
  api.addFiles('everywhere/reactivewrapper.coffee');
  api.addFiles('everywhere/rectangle.coffee');

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
  api.addFiles('mirage/render.coffee');
  api.addFiles('mirage/render.html');
  api.addFiles('mirage/window.coffee', 'client');

  api.addFiles('mirage/spacebars/meteorhelpers.coffee');
  api.addFiles('mirage/spacebars/stringhelpers.coffee');

  api.addFiles('mirage/mixins/autoresizetextarea.coffee');
  api.addFiles('mirage/mixins/autoselectinput.coffee');
  api.addFiles('mirage/mixins/persistentinput.coffee');

  // Artificial Base
  // Depends on Artificial Mirage.
  api.addFiles('base/base.coffee');

  api.addFiles('base/app.coffee');
  api.addFiles('base/app.html');

  // Artificial Mummification
  api.addFiles('mummification/mummification.coffee');

  api.addFiles('mummification/mongohelper.coffee');
  api.addFiles('mummification/document.coffee');

  // Artificial Telepathy
  api.addFiles('telepathy/telepathy.coffee');

  api.addFiles('telepathy/flowrouter/addroute.coffee');
  api.addFiles('telepathy/flowrouter/spacebars.coffee');

	api.addFiles('telepathy/flowrouter/routelink.coffee');
	api.addFiles('telepathy/flowrouter/routelink.html');

  api.addFiles('telepathy/emailcomposer.coffee');

  // Artificial Babel
  api.addFiles('babel/babel.coffee');
  api.addFiles('babel/initialize.coffee');

  api.addFiles('babel/translation/translation.coffee');
  api.addFiles('babel/translation/subscriptions.coffee', 'server');
  api.addFiles('babel/translation/methods.coffee');

  api.addFiles('babel/components/components.coffee');

  api.addFiles('babel/components/translatable/translatable.html');
  api.addFiles('babel/components/translatable/translatable.coffee');

  api.addFiles('babel/components/translation/translation.html');
  api.addFiles('babel/components/translation/translation.coffee');
});
