Package.describe({
  name: 'retronator:pixelartacademy-practice',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'quill-delta': '4.2.2',
  'path-data-polyfill': '1.0.4'
});

Package.onUse(function(api) {
  api.use('retronator:retronator-accounts');
  api.use('retronator:landsofillusions-assets');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:pixelartdatabase');
  api.use('froatsnook:request');

  api.use('jparker:crypto-aes');

  api.export('PixelArtAcademy');

  api.addFile('practice');

  // Journal

  api.addFile('journal..');
  api.addFile('journal/methods');
  api.addServerFile('journal/subscriptions');

  api.addFile('journal/entry..');
  api.addFile('journal/entry/methods');
  api.addServerFile('journal/entry/subscriptions');
  api.addFile('journal/entry/action');
  api.addFile('journal/entry/avatar');

  // Pages

  api.addFile('pages/pages');

  api.addUnstyledComponent('pages/admin..');
  api.addUnstyledComponent('pages/admin/scripts..');
  api.addServerFile('pages/admin/scripts/methods-server/convertcheckins');

  api.addUnstyledComponent('pages/admin/projects..');
  api.addServerFile('pages/admin/projects/methods-server');

  // Check-ins (legacy)

  api.addFile('checkin/checkin');
  api.addFile('checkin/methods');
  api.addServerFile('checkin/methods-server');
  api.addServerFile('checkin/subscriptions');
  api.addServerFile('checkin/migrations/0000-renamecollection');
  api.addServerFile('checkin/migrations/0001-characterreferencefieldsupdate');
  api.addServerFile('checkin/migrations/0002-removecharacternamefield');
  api.addServerFile('checkin/migrations/0003-changetomemories');

  api.addFile('importeddata/importeddata');
  api.addServerFile('importeddata/checkin-server/checkin');
  api.addServerFile('importeddata/checkin-server/migrations/0000-renamecollection');

  api.addUnstyledComponent('pages/extractimagesfromposts/extractimagesfromposts');
  api.addServerFile('pages/extractimagesfromposts/methods-server');

  api.addComponent('pages/importcheckins/importcheckins');
  api.addServerFile('pages/importcheckins/methods-server');

  // Helpers

  api.addFile('helpers..')
  api.addFile('helpers/drawing..')
  api.addFile('helpers/drawing/markup..')
  api.addFile('helpers/drawing/markup/pixelart')
  api.addFile('helpers/drawing/markup/enginecomponent')

  // Project

  api.addFile('project..');
  api.addServerFile('project/project-server-databasecontent');
  api.addFile('project/subscriptions');
  api.addServerFile('project/subscriptions-server');

  api.addFile('project/thing');
  api.addFile('project/workbench');
  api.addFile('project/asset');

  api.addFile('project/assets/bitmap..');
  api.addComponent('project/assets/bitmap/portfoliocomponent..');
  api.addComponent('project/assets/bitmap/clipboardcomponent..');
  api.addUnstyledComponent('project/assets/bitmap/briefcomponent..');

  // Challenges

  api.addFile('challenges..');
  api.addFile('challenges/drawing..');

  // Tutorials

  api.addFile('tutorials..');
  api.addFile('tutorials/drawing..');
  api.addFile('tutorials/drawing/tutorial');
  api.addFile('tutorials/drawing/instructionsmarkupenginecomponent');

  api.addFile('tutorials/drawing/assets..');

  api.addFile('tutorials/drawing/assets/tutorialbitmap..');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-steps');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-resources');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-references');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-create');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/tutorialbitmap-reset');

  api.addFile('tutorials/drawing/assets/tutorialbitmap/hintsenginecomponent');

  api.addComponent('tutorials/drawing/assets/tutorialbitmap/portfoliocomponent..');
  api.addUnstyledComponent('tutorials/drawing/assets/tutorialbitmap/briefcomponent..');

  api.addFile('tutorials/drawing/assets/tutorialbitmap/resource..');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/resource/pixels');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/resource/bitmapstringpixels');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/resource/imagepixels');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/resource/svgpaths');

  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/steparea');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/step');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/pixelsstep');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/pixelswithpathsstep');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/ephemeralstep');

  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/pathstep..');
  api.addFile('tutorials/drawing/assets/tutorialbitmap/steps/pathstep/path');

  // Software

  api.addFile('software..');
  api.addFile('software/tools');

  // Artworks

  api.addFile('artworks..');

  // Pixel art evaluation

  api.addFile('pixelartevaluation..')
  api.addFile('pixelartevaluation/layer')
  api.addFile('pixelartevaluation/core')
  api.addFile('pixelartevaluation/pixel')
  api.addFile('pixelartevaluation/point')
  api.addFile('pixelartevaluation/point-optimizeneighbors')

  api.addFile('pixelartevaluation/line..')
  api.addFile('pixelartevaluation/line/line-addoutlinepoints')
  api.addFile('pixelartevaluation/line/line-classifylineparts')
  api.addFile('pixelartevaluation/line/line-detectstraightlineparts')
  api.addFile('pixelartevaluation/line/line-detectcurveparts')
  api.addFile('pixelartevaluation/line/line-createparts')
  api.addFile('pixelartevaluation/line/line-analyzecurvature')
  api.addFile('pixelartevaluation/line/line-evaluate')
  api.addFile('pixelartevaluation/line/part..')
  api.addFile('pixelartevaluation/line/part/straightline')
  api.addFile('pixelartevaluation/line/part/straightline-evaluate')
  api.addFile('pixelartevaluation/line/part/straightline-getsegmentcorners')
  api.addFile('pixelartevaluation/line/part/curve')
  api.addFile('pixelartevaluation/line/part/curve-evaluate')
  api.addFile('pixelartevaluation/line/part/curve-calculatepointconfidence')

  // Engine component requires lines to be defined.
  api.addFile('pixelartevaluation/enginecomponent')
  api.addFile('pixelartevaluation/enginecomponent-debug')
});
