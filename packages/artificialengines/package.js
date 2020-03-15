Package.describe({
  name: 'retronator:artificialengines',
  version: '1.0.0'
});

Npm.depends({
  twit: '2.2.9',
  stripe: '5.1.1',
  patreon: '0.3.0',
  'tumblr.js': '1.1.1',
  'path-to-regexp': '2.1.0',
  three: '0.114.0',
  'jaro-winkler': '0.2.8',
  'canvas': '2.3.1',
  'pako': '1.0.8',
  'bson': '4.0.2',
  'text-encoder-lite': '2.0.0'
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
    'retronator:blaze-components',
    'peerlibrary:reactive-field',
    'peerlibrary:computed-field',
    'peerlibrary:check-extension',
    'peerlibrary:server-autorun',
    'peerlibrary:blocking',
    'peerlibrary:directcollection',
    'okgrow:router-autoscroll',
    'stevezhu:lodash',
    'velocityjs:velocityjs',
    'meteorhacks:picker',
    'meteorhacks:inject-initial',

    // Custom API extensions
    'retronator:api'
  ];

	api.use(packages);
  api.imply(packages);

  api.use('webapp', 'server');
  api.use('froatsnook:request', 'server');

  api.export('Artificial');
  api.export('THREE');
  api.export('Ammo');

	api.addFile('artificial');

	// Global initialization
  
	api.addFile('everywhere/lodash/lodash');

	// Define all namespaces so that we can use shortcuts.

  api.addFile('everywhere..');
  api.addFile('control..');
  api.addFile('mirage..');
  api.addFile('base..');
  api.addFile('mummification..');
  api.addFile('telepathy..');
  api.addFile('babel..');
  api.addFile('program..');
  api.addFile('pyramid..');
  api.addFile('spectrum..');
  api.addFile('reality..');
  api.addFile('echo..');
  api.addFile('everything..');

  // Artificial Everywhere

  api.addClientFile('everywhere/jquery/positioncss');

  api.addFile('everywhere/three..');
  api.addGlsl('everywhere/three..');
  api.addFile('everywhere/three/color');
  api.addFile('everywhere/three/vectors');
  api.addFile('everywhere/three/quaternion');
  api.addFile('everywhere/three/matrices');
  api.addFile('everywhere/three/object3d');

  api.addFile('everywhere/lodash/lettercase');
  api.addFile('everywhere/lodash/nestedproperty');
  api.addFile('everywhere/lodash/urls');
  api.addFile('everywhere/lodash/math');
  api.addFile('everywhere/lodash/objects');
  api.addFile('everywhere/lodash/strings');
  api.addFile('everywhere/lodash/filterfunction');
  api.addFile('everywhere/lodash/inherit');
  api.addFile('everywhere/lodash/parse');

  api.addFile('everywhere/tracker/delayedautorun');

  api.addFile('everywhere/csvparser');
  api.addFile('everywhere/date');
  api.addFile('everywhere/datehelper');
  api.addFile('everywhere/daterange');
  api.addFile('everywhere/exceptions');
  api.addFile('everywhere/match');
  api.addFile('everywhere/reactivearray');
  api.addFile('everywhere/reactivedictionary');
  api.addFile('everywhere/reactivewrapper');
  api.addFile('everywhere/rectangle');

  // Artificial Control

  api.addFile('control/keyboard');
  api.addFile('control/keyboardstate');
  api.addFile('control/keys');

  // Artificial Mirage

  api.addClientFile('mirage/browser');
  api.addFile('mirage/canvas');
	api.addFile('mirage/component');
	api.addFile('mirage/csshelper');
  api.addUnstyledComponent('mirage/datainput');
	api.addCss('mirage/debugfont');
  api.addStyleImport('mirage/debugfont');
	api.addComponent('mirage/display');
  api.addStyleImport('mirage/helpers');
  api.addFile('mirage/htmlhelper');
  api.addUnstyledComponent('mirage/pixelimage');
  api.addUnstyledComponent('mirage/render');
  api.addFile('mirage/shortcuthelper');
  api.addClientFile('mirage/window');

  api.addUnstyledComponent('mirage/markdown..');

  api.addFile('mirage/spacebars/meteorhelpers');
  api.addFile('mirage/spacebars/stringhelpers');
  api.addFile('mirage/spacebars/numberhelpers');
  api.addFile('mirage/spacebars/htmlhelpers');
  api.addFile('mirage/spacebars/image');
  api.addFile('mirage/spacebars/uncached');
  api.addFile('mirage/spacebars/debughelpers');

  api.addFile('mirage/mixins/autoresizetextarea');
  api.addFile('mirage/mixins/autoselectinput');
  api.addFile('mirage/mixins/persistentinput');

  api.addFile('mirage/mixins/fullscreenscrolling..');
  api.addStyle('mirage/mixins/fullscreenscrolling..');

  // Artificial Base
  
  // Depends on Artificial Mirage.
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

  api.addFile('mummification/mongohelper');
  api.addFile('mummification/document');
  api.addFile('mummification/persistentstorage');
  api.addFile('mummification/collectionwrapper');
  api.addServerFile('mummification/directcollection');
  api.addFile('mummification/embeddedimagedata');

  api.addFile('mummification/hierarchy..');
  api.addFile('mummification/hierarchy/address');
  api.addFile('mummification/hierarchy/node');
  api.addFile('mummification/hierarchy/field');
  api.addFile('mummification/hierarchy/template');
  api.addFile('mummification/hierarchy/location');

  // Game content

  api.addServerFile('mummification/databasecontent-server/databasecontent');
  api.addServerFile('mummification/databasecontent-server/initialize');

  // Depends on Artificial Base.
  api.addFile('mummification/admin..');
  api.addFile('mummification/admin/components..');
  api.addComponent('mummification/admin/components/adminpage..');
  api.addComponent('mummification/admin/components/index..');
  api.addFile('mummification/admin/components/document..');
  
  // Artificial Telepathy

  api.addFile('telepathy/emailcomposer');
  api.addFile('telepathy/requesthelper');

  api.addServerFile('telepathy/twitter-server');
  api.addServerFile('telepathy/stripe-server');
  api.addServerFile('telepathy/patreon-server');
  api.addServerFile('telepathy/tumblr-server');
  api.addServerFile('telepathy/maxmind-server');

  // Artificial Babel

  api.addServerFile('babel/babel-server');
  api.addClientFile('babel/babel-client');
  api.addClientFile('babel/initialize-client');
  api.addFile('babel/helpers..');
  api.addFile('babel/helpers/translations');
  api.addServerFile('babel/cache-server');

  api.addFile('babel/rules..');
  api.addFile('babel/rules/english');

  api.addFile('babel/lodash/languageregion');

  api.addFile('babel/translation/translation');
  api.addServerFile('babel/translation/translation-server-databasecontent');
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

  // Artificial Program

  api.addFile('program/search..');

  // Artificial Pyramid
  api.addGlsl('pyramid/trigonometry');

  api.addFile('pyramid/complexnumber');
  api.addGlsl('pyramid/complexnumber');

  api.addFile('pyramid/integration..');
  api.addFile('pyramid/integration/midpoint');

  api.addFile('pyramid/interpolation..');
  api.addFile('pyramid/interpolation/lagrangepolynomial');
  api.addFile('pyramid/interpolation/piecewisepolynomial');
  api.addFile('pyramid/interpolation/cachedfunction2d');

  // Artificial Reality

  api.addFile('reality/reality-constants');
  api.addFile('reality/reality-units');
  api.addFile('reality/conversions');

  api.addJavascript('reality/ammo/build/ammo');
  api.addFile('reality/ammo..');

  api.addFile('reality/physicsobject');

  api.addFile('reality/ammo/vectors');
  api.addFile('reality/ammo/quaternion');
  api.addFile('reality/ammo/collisionobject');

  api.addFile('reality/optics..');

  api.addFileWithGlsl('reality/optics/snellslaw');
  api.addFileWithGlsl('reality/optics/fresnelequations');
  api.addFile('reality/optics/scattering');

  api.addFile('reality/optics/spectrum..');
  api.addFile('reality/optics/spectrum/formulated');
  api.addFile('reality/optics/spectrum/sampled');
  api.addFile('reality/optics/spectrum/array');
  api.addFile('reality/optics/spectrum/xyz');
  api.addFile('reality/optics/spectrum/rgb');
  api.addFile('reality/optics/spectrum/uniformlysampled..');
  api.addFile('reality/optics/spectrum/uniformlysampled/range380to780spacing5');

  api.addFile('reality/optics/lightsources..');
  api.addFile('reality/optics/lightsources/lightsource');
  api.addFile('reality/optics/lightsources/tabulatedlightsource');
  api.addFile('reality/optics/lightsources/blackbody');

  api.addFile('reality/optics/lightsources/cie..');
  api.addFile('reality/optics/lightsources/cie/d');
  api.addFile('reality/optics/lightsources/cie/d-data');
  api.addFile('reality/optics/lightsources/cie/d65');
  api.addFile('reality/optics/lightsources/cie/d65-data');

  api.addFile('reality/optics/lightsources/cie/a..');
  api.addFile('reality/optics/lightsources/cie/a/formulated');
  api.addFile('reality/optics/lightsources/cie/a/tabulated');
  api.addFile('reality/optics/lightsources/cie/a/tabulated-data');

  // Chemistry depends on optics.
  api.addFile('reality/chemistry..');

  api.addFile('reality/chemistry/materials..');
  api.addFile('reality/chemistry/materials/material');
  api.addFile('reality/chemistry/materials/tabulatedmaterial');
  api.addFile('reality/chemistry/materials/gas');
  api.addFile('reality/chemistry/materials/gas-vanderwaals');
  api.addFile('reality/chemistry/materials/idealgas');

  api.addFile('reality/chemistry/materials/elements..');
  api.addFile('reality/chemistry/materials/elements/argon');
  api.addFile('reality/chemistry/materials/elements/calcium');
  api.addFile('reality/chemistry/materials/elements/carbon');
  api.addFile('reality/chemistry/materials/elements/carbon-diamond');
  api.addFile('reality/chemistry/materials/elements/carbon-graphite');
  api.addFile('reality/chemistry/materials/elements/chromium');
  api.addFile('reality/chemistry/materials/elements/copper');
  api.addFile('reality/chemistry/materials/elements/gold');
  api.addFile('reality/chemistry/materials/elements/helium');
  api.addFile('reality/chemistry/materials/elements/hydrogen');
  api.addFile('reality/chemistry/materials/elements/iron');
  api.addFile('reality/chemistry/materials/elements/mercury');
  api.addFile('reality/chemistry/materials/elements/neon');
  api.addFile('reality/chemistry/materials/elements/nitrogen');
  api.addFile('reality/chemistry/materials/elements/oxygen');
  api.addFile('reality/chemistry/materials/elements/potassium');
  api.addFile('reality/chemistry/materials/elements/silver');
  api.addFile('reality/chemistry/materials/elements/sodium');

  api.addFile('reality/chemistry/materials/compounds..');
  api.addFile('reality/chemistry/materials/compounds/carbondioxide');
  api.addFile('reality/chemistry/materials/compounds/corundum');
  api.addFile('reality/chemistry/materials/compounds/tungstendisulfide');
  api.addFile('reality/chemistry/materials/compounds/water');
  api.addFile('reality/chemistry/materials/compounds/watervapor');

  api.addFile('reality/chemistry/materials/mixtures..');
  api.addFile('reality/chemistry/materials/mixtures/gasmixture');

  api.addFile('reality/chemistry/materials/mixtures/glass..');
  api.addFile('reality/chemistry/materials/mixtures/glass/crown');
  api.addFile('reality/chemistry/materials/mixtures/glass/flint');

  api.addFile('reality/chemistry/materials/mixtures/air..');
  api.addFile('reality/chemistry/materials/mixtures/air/drydirect');
  api.addFile('reality/chemistry/materials/mixtures/air/drymixture');
  api.addFile('reality/chemistry/materials/mixtures/air/moistmixture3percent');
  api.addFile('reality/chemistry/materials/mixtures/air/marsmixture');

  api.addFile('reality/chemistry/materials/mixtures/stars..');
  api.addFile('reality/chemistry/materials/mixtures/stars/sun');

  // Artificial Spectrum

  api.addFile('spectrum/renderobject');
  api.addFile('spectrum/animatedmesh');
  api.addFile('spectrum/imagedatahelpers');
  api.addFile('spectrum/shadowmapdebugmaterial');

  api.addClientJavascript('spectrum/creature/glmatrix');
  api.addClientJavascript('spectrum/creature/creaturemeshbone');
  api.addClientJavascript('spectrum/creature/creaturerenderer');

  api.addFile('spectrum/hqx..');
  api.addJavascript('spectrum/hqx..');


  api.addFile('spectrum/color..');
  api.addGlsl('spectrum/color/hsltorgb');

  api.addFile('spectrum/color/cie1931..');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions..');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions/colormatchingfunctions-data');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions/approximate');

  api.addFile('spectrum/color/srgb..');

  // Artificial Echo

  // Artificial Everything

  api.addFile('everything/item');
  api.addFile('everything/part');
});
