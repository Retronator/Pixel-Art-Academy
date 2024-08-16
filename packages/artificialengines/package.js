Package.describe({
  name: 'retronator:artificialengines',
  version: '1.0.0'
});

Npm.depends({
  'path-to-regexp': '2.1.0',
  'three': '0.126.1',
  'canvas': '2.11.2',
  'pako': '1.0.8',
  'bson': '4.0.2',
  'text-encoder-lite': '2.0.0',
  'quill': '1.3.7',
  "velocity-animate": "1.5.2",
  'showdown': '1.9.1',
  'lodash': '4.17.21',
  'poly-decomp': '0.3.0'
});

Package.onUse(function(api) {
  var packages = [
    // Meteor
    'coffeescript',
    'spacebars',
    'tracker',
    'mongo',
    'ddp-client',
    'random',
    'reactive-var',
    'reactive-dict',
    'check',
    'ejson',
    'http',
    'fetch',
    'oauth',
    'modules',
    'stylus',
    'logging',

    // 3rd party
    'retronator:peerdb',
    'retronator:peerdb-migrations',
    'retronator:blaze-components',
    'retronator:blaze-common-component',
    'peerlibrary:reactive-field',
    'peerlibrary:computed-field',
    'peerlibrary:check-extension',
    'peerlibrary:server-autorun',
    'retronator:directcollection',
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
  api.export('_');
  api.export('THREE');
  api.export('Ammo');

  api.addClientJavascript('everywhere/consolefix');

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
  api.addFile('melody..');
  api.addFile('everything..');
  api.addFile('workforce..');

  // Artificial Everywhere

  api.addClientFile('everywhere/jquery/positioncss');

  api.addFile('everywhere/three..');
  api.addGlsl('everywhere/three..');
  api.addClientFile('everywhere/three/loaders');
  api.addClientFile('everywhere/three/utils');
  api.addFile('everywhere/three/color');
  api.addFile('everywhere/three/vectors');
  api.addFile('everywhere/three/quaternion');
  api.addFile('everywhere/three/matrices');
  api.addFile('everywhere/three/object3d');
  api.addFile('everywhere/three/line2');
  api.addFile('everywhere/three/triangle2');

  api.addFile('everywhere/lodash/lettercase');
  api.addFile('everywhere/lodash/nestedproperty');
  api.addFile('everywhere/lodash/urls');
  api.addFile('everywhere/lodash/math');
  api.addFile('everywhere/lodash/objects');
  api.addFile('everywhere/lodash/strings');
  api.addFile('everywhere/lodash/filterfunction');
  api.addFile('everywhere/lodash/inherit');
  api.addFile('everywhere/lodash/parse');
  api.addFile('everywhere/lodash/transform');
  api.addFile('everywhere/lodash/cartesianproduct');
  api.addFile('everywhere/lodash/time');

  api.addFile('everywhere/tracker/delayedautorun');
  api.addFile('everywhere/tracker/triggerondefinedchange');

  api.addFile('everywhere/csvparser');
  api.addFile('everywhere/date');
  api.addFile('everywhere/datehelper');
  api.addFile('everywhere/daterange');
  api.addFile('everywhere/exceptions');
  api.addFile('everywhere/livecomputedfield');
  api.addFile('everywhere/match');
  api.addFile('everywhere/reactivefield');
  api.addFile('everywhere/reactivearray');
  api.addFile('everywhere/reactivedictionary');
  api.addFile('everywhere/reactiveinstances');
  api.addFile('everywhere/reactivewrapper');
  api.addFile('everywhere/rectangle');

  // Artificial Control

  api.addFile('control/keyboard');
  api.addFile('control/keyboardstate');
  api.addFile('control/keys');
  api.addFile('control/pointer');
  api.addFile('control/pointerstate');
  api.addFile('control/buttons');
  api.addFile('control/discretewheeleventlistener');

  // Artificial Mirage

  api.addClientFile('mirage/browser-client');
  api.addFile('mirage/canvas');
  api.addFile('mirage/component');
  api.addFile('mirage/csshelper');
  api.addStyleImport('mirage/helpers');
  api.addFile('mirage/htmlhelper');
  api.addFile('mirage/shortcuthelper');
  api.addClientFile('mirage/velocity-client');
  api.addClientFile('mirage/window-client');

  api.addUnstyledComponent('mirage/datainput..');

  api.addCss('mirage/debugfont..');
  api.addStyleImport('mirage/debugfont..');

  api.addComponent('mirage/display..');

  api.addUnstyledComponent('mirage/hdrimage..');

  api.addUnstyledComponent('mirage/markdown..');

  api.addFile('mirage/mixins/fullscreenscrolling..');
  api.addStyle('mirage/mixins/fullscreenscrolling..');

  api.addUnstyledComponent('mirage/pixelimage..');

  api.addClientFile('mirage/quill-client/quill');
  api.addClientFile('mirage/quill-client/blotcomponent');

  api.addUnstyledComponent('mirage/render..');

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

  // Artificial Base

  // Depends on Artificial Mirage.
  api.addUnstyledComponent('base/app');

  api.addFile('base/method');
  api.addFile('base/subscription');
  api.addFile('base/event');

  api.addFile('base/versionproperty..');
  api.addFile('base/versionproperty/operatingsystem');
  api.addFile('base/versionproperty/distributionplatform');
  api.addFile('base/versionproperty/applicationenvironment');

  api.addFile('base/router/router');
  api.addServerFile('base/router/router-server');
  api.addClientFile('base/router/router-client');
  api.addFile('base/router/route');
  api.addFile('base/router/spacebars');
  api.addUnstyledComponent('base/router/routelink');

  // Artificial Mummification

  api.addFile('mummification/collection');
  api.addFile('mummification/mongohelper');
  api.addFile('mummification/persistentstorage');
  api.addFile('mummification/collectionwrapper');
  api.addFile('mummification/embeddedimagedata');

  api.addFile('mummification/document..');

  api.addFile('mummification/document/persistence..');
  api.addFile('mummification/document/persistence/persistentcollection');
  api.addFile('mummification/document/persistence/syncedstorage');

  api.addFile('mummification/document/persistence/syncedstorages..');
  api.addFile('mummification/document/persistence/syncedstorages/localstorage');
  api.addFile('mummification/document/persistence/syncedstorages/filesystem');

  // We add profile last since it's a persistent document itself.
  api.addFile('mummification/document/persistence/profile');

  api.addFile('mummification/document/versioning..');
  api.addFile('mummification/document/versioning/versioning-execute');
  api.addFile('mummification/document/versioning/versioning-history');
  api.addFile('mummification/document/versioning/versioning-history-sync');
  api.addFile('mummification/document/versioning/versionedcollection');
  api.addClientFile('mummification/document/versioning/versionedcollection-client');
  api.addClientFile('mummification/document/versioning/versioneddocumentloader-client');
  api.addFile('mummification/document/versioning/operation');
  api.addFile('mummification/document/versioning/action');
  api.addFile('mummification/document/versioning/actionarchive');

  api.addFile('mummification/hierarchy..');
  api.addFile('mummification/hierarchy/address');
  api.addFile('mummification/hierarchy/node');
  api.addFile('mummification/hierarchy/field');
  api.addFile('mummification/hierarchy/template');
  api.addFile('mummification/hierarchy/location');

  // Game content

  api.addServerFile('mummification/documentcaches-server/documentcaches');

  api.addFile('mummification/databasecontent..');
  api.addServerFile('mummification/databasecontent/databasecontent-server');
  api.addClientFile('mummification/databasecontent/databasecontent-client');
  api.addClientFile('mummification/databasecontent/contentcollection-client');
  api.addFile('mummification/databasecontent/subscription');
  api.addServerFile('mummification/databasecontent/initialize-server');
  api.addClientFile('mummification/databasecontent/initialize-client');

  // Depends on Artificial Base.
  api.addFile('mummification/admin..');
  api.addFile('mummification/admin/components..');
  api.addComponent('mummification/admin/components/adminpage..');
  api.addComponent('mummification/admin/components/index..');
  api.addFile('mummification/admin/components/document..');

  // Artificial Telepathy

  api.addFile('telepathy/emailcomposer');
  api.addFile('telepathy/requesthelper');

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

  api.addFile('program/hashfunctions');

  api.addFile('program/search..');

  // Artificial Pyramid
  api.addGlsl('pyramid/trigonometry');
  api.addGlsl('pyramid/integeroperations');

  api.addFile('pyramid/complexnumber');
  api.addGlsl('pyramid/complexnumber');

  api.addFile('pyramid/fraction');

  api.addFile('pyramid/besselfunctions');

  api.addFile('pyramid/integration..');
  api.addFile('pyramid/integration/midpoint');

  api.addFile('pyramid/interpolation..');
  api.addFile('pyramid/interpolation/lagrangepolynomial');
  api.addFile('pyramid/interpolation/piecewisepolynomial');
  api.addFile('pyramid/interpolation/cachedfunction2d');

  api.addFileWithGlsl('pyramid/octahedronmap..');

  api.addFile('pyramid/boundingrectangle');

  api.addFile('pyramid/polygon');
  api.addFile('pyramid/polygonboundary');
  api.addFile('pyramid/polygonwithholes');

  api.addFile('pyramid/beziercurve');

  // Artificial Reality

  api.addFile('reality/reality-constants');
  api.addFile('reality/reality-units');
  api.addFile('reality/conversions');

  api.addClientJavascript('reality/ammo/build/ammo');
  api.addClientFile('reality/ammo..');

  api.addFile('reality/physicsobject');
  api.addFile('reality/trigger');

  api.addClientFile('reality/ammo/vectors');
  api.addClientFile('reality/ammo/quaternion');
  api.addClientFile('reality/ammo/collisionobject');

  api.addFile('reality/optics..');

  api.addFileWithGlsl('reality/optics/snellslaw');
  api.addFileWithGlsl('reality/optics/fresnelequations');
  api.addFile('reality/optics/scattering');
  api.addGlsl('reality/optics/scattering');
  api.addFile('reality/optics/scattering-mie');

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
  api.addFile('reality/chemistry/materials/sellmeiermaterial');

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
  api.addFile('reality/chemistry/materials/compounds/cellulose');
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

  api.addFile('spectrum/renderobject..');
  api.addFile('spectrum/animatedmesh..');
  api.addFile('spectrum/imagedatahelpers..');
  api.addFile('spectrum/shadowmapdebugmaterial..');
  api.addFile('spectrum/screenquad..');

  api.addClientJavascript('spectrum/creature/glmatrix');
  api.addClientJavascript('spectrum/creature/creaturemeshbone');
  api.addClientJavascript('spectrum/creature/creaturerenderer');

  api.addFile('spectrum/hqx..');
  api.addJavascript('spectrum/hqx..');

  api.addClientJavascript('spectrum/previewgif-client/previewgif');

  api.addFile('spectrum/pixelart..');
  api.addFile('spectrum/pixelart/pixelart-detectpixelscale');
  api.addFile('spectrum/pixelart/pixelart-getditherthresholdmap');

  api.addFile('spectrum/color..');
  api.addGlsl('spectrum/color/hsltorgb');

  api.addFile('spectrum/color/cie1931..');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions..');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions/colormatchingfunctions-data');
  api.addFile('spectrum/color/cie1931/colormatchingfunctions/approximate');

  api.addFile('spectrum/color/srgb..');

  // Artificial Echo

  api.addFile('echo/audio');
  api.addFile('echo/variable');
  api.addFile('echo/node');

  api.addFile('echo/nodes/output');
  api.addFile('echo/nodes/sound');

  api.addFile('echo/nodes/schedulednode');
  api.addFile('echo/nodes/player');
  api.addFile('echo/nodes/constant');
  api.addFile('echo/nodes/oscillator');

  api.addFile('echo/nodes/adsr');

  api.addFile('echo/nodes/gain');
  api.addFile('echo/nodes/delay');
  api.addFile('echo/nodes/biquadfilter');
  api.addFile('echo/nodes/mixer');
  api.addFile('echo/nodes/stereopanner');
  api.addFile('echo/nodes/convolver');

  api.addFile('echo/nodes/variable');
  api.addFile('echo/nodes/number');
  api.addFile('echo/nodes/boolean');

  api.addFile('echo/nodes/sustainvalue');
  api.addFile('echo/nodes/keepvalue');
  api.addFile('echo/nodes/clamp');
  api.addFile('echo/nodes/equation');

  api.addFile('echo/nodes/randomnumber');
  api.addFile('echo/nodes/randombuffer');

  api.addFile('echo/nodes/valueequals');
  api.addFile('echo/nodes/valuechange');

  // Artificial Melody

  api.addFile('melody/composition');
  api.addFile('melody/section');
  api.addFile('melody/transition');
  api.addFile('melody/event');
  api.addFile('melody/sectionhandle');
  api.addFile('melody/eventhandle');
  api.addFile('melody/playback');

  api.addFile('melody/events/player');

  // Artificial Everything

  api.addFile('everything/item');
  api.addFile('everything/part');

  // Artificial Workforce

  api.addFile('workforce/work');
});
