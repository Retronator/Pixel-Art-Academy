Package.describe({
  name: 'retronator:pixelartacademy-season1-episode1',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-season1');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartacademy-actors');
  api.use('retronator:pixelartdatabase');
  api.use('retronator:retronator-hq');
  api.use('retronator:retronator-landsofillusions');
  api.use('retronator:retronator-residence');
  api.use('retronator:sanfrancisco-soma');
  api.use('retronator:sanfrancisco-c3');
  api.use('retronator:sanfrancisco-apartment');

  api.export('PixelArtAcademy');

  api.addFile('episode1');
  api.addFile('scenes/inventory');
  api.addFile('scenes/chinabasinpark');
  api.addFile('scenes/store');

  // Admin

  api.addFile('pages..');
  api.addUnstyledComponent('pages/admin..');
  api.addUnstyledComponent('pages/admin/admissions..');
  api.addServerFile('pages/admin/admissions/methods-server/processapplied');

  // Start

  api.addFile('start..');
  api.addThing('start/scenes/wakeup');

  // Chapter 1: Admission Week

  api.addFile('chapter1..');
  api.addServerFile('chapter1/chapter1-server');
  api.addServerFile('chapter1/methods-server');

  api.addFile('chapter1/events..');
  api.addFile('chapter1/events/applicationaccepted');

  api.addFile('chapter1/items..');
  api.addFile('chapter1/items/applicationemail');
  api.addFile('chapter1/items/admissionemail');

  api.addFile('chapter1/scenes/inventory');
  api.addFile('chapter1/scenes/inbox');
  api.addFile('chapter1/scenes/apps');
  api.addFile('chapter1/scenes/editors');
  api.addFile('chapter1/scenes/workbench');
  api.addFile('chapter1/scenes/pico8cartridges');
  api.addThing('chapter1/scenes/sanfranciscoconversation');

  api.addFile('chapter1/goals..');
  api.addFile('chapter1/goals/drawingsoftware');
  api.addFile('chapter1/goals/physicalpixelart');
  api.addFile('chapter1/goals/pixelartsoftware');
  api.addFile('chapter1/goals/traditionalarttools');
  api.addFile('chapter1/goals/time');
  api.addFile('chapter1/goals/studygroup');
  api.addFile('chapter1/goals/studyplan');
  api.addFile('chapter1/goals/admission');
  api.addFile('chapter1/goals/snake');

  api.addFile('chapter1/groups..');
  api.addThing('chapter1/groups/sanfranciscofriends');
  api.addThing('chapter1/groups/sanfranciscofriends-conversation');
  api.addFile('chapter1/groups/family');

  api.addThing('chapter1/groups/admissionsstudygroup..');
  api.addFile('chapter1/groups/admissionsstudygroup/a');
  api.addFile('chapter1/groups/admissionsstudygroup/b');
  api.addFile('chapter1/groups/admissionsstudygroup/c');

  api.addFile('chapter1/projects..');
  api.addFile('chapter1/projects/snake');
  api.addServerFile('chapter1/projects/snake-methods-server');

  api.addFile('chapter1/challenges..');
  api.addFile('chapter1/challenges/drawing..');

  api.addFile('chapter1/challenges/drawing/pixelartsoftware..');
  api.addFile('chapter1/challenges/drawing/pixelartsoftware/copyreference');
  api.addFile('chapter1/challenges/drawing/pixelartsoftware/errorenginecomponent');
  api.addFile('chapter1/challenges/drawing/pixelartsoftware/assets');
  api.addUnstyledComponent('chapter1/challenges/drawing/pixelartsoftware/briefcomponent..');
  api.addComponent('chapter1/challenges/drawing/pixelartsoftware/clipboardpagecomponent..');

  api.addFile('chapter1/challenges/drawing/tutorial..');

  api.addFile('chapter1/challenges/drawing/tutorial/basics..');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/pencil');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/eraser');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/colorfill');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/colorfill2');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/colorfill3');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/basictools');
  api.addFile('chapter1/challenges/drawing/tutorial/basics/shortcuts');

  api.addFile('chapter1/challenges/drawing/tutorial/colors..');
  api.addFile('chapter1/challenges/drawing/tutorial/colors/colorswatches');
  api.addFile('chapter1/challenges/drawing/tutorial/colors/colorpicking');
  api.addFile('chapter1/challenges/drawing/tutorial/colors/quickcolorpicking');
  api.addServerFile('chapter1/challenges/drawing/tutorial/colors/palette-server');

  api.addFile('chapter1/challenges/drawing/tutorial/helpers..');
  api.addFile('chapter1/challenges/drawing/tutorial/helpers/zoom');
  api.addFile('chapter1/challenges/drawing/tutorial/helpers/movecanvas');
  api.addFile('chapter1/challenges/drawing/tutorial/helpers/undoredo');
  api.addFile('chapter1/challenges/drawing/tutorial/helpers/references');

  // Intro
  api.addFile('chapter1/sections/intro..');
  api.addThing('chapter1/sections/intro/scenes/studio');

  // Waiting
  api.addFile('chapter1/sections/waiting..');

  // Pre-PixelBoy
  api.addFile('chapter1/sections/prepixelboy..');
  api.addThing('chapter1/sections/prepixelboy/scenes/store');

  // PixelBoy
  api.addFile('chapter1/sections/pixelboy..');
  api.addThing('chapter1/sections/pixelboy/scenes/store');

  // Post-PixelBoy
  api.addFile('chapter1/sections/postpixelboy..');
  api.addFile('chapter1/sections/postpixelboy/scenes/drawingchallenges');
  api.addThing('chapter1/sections/postpixelboy/scenes/store');
  api.addThing('chapter1/sections/postpixelboy/scenes/pixelart');
  api.addFile('chapter1/sections/postpixelboy/scenes/copyreference..');
  api.addThing('chapter1/sections/postpixelboy/scenes/copyreference/galleryeast');
  api.addThing('chapter1/sections/postpixelboy/scenes/copyreference/gallerywest');
  api.addThing('chapter1/sections/postpixelboy/scenes/copyreference/store');
  api.addThing('chapter1/sections/postpixelboy/scenes/copyreference/bookshelves');

  // Admission projects
  api.addFile('chapter1/sections/admissionprojects..');

  // Snake
  api.addFile('chapter1/sections/admissionprojects/snake..');

  api.addFile('chapter1/sections/admissionprojects/snake/intro..');
  api.addThing('chapter1/sections/admissionprojects/snake/intro/scenes/coworking');

  api.addFile('chapter1/sections/admissionprojects/snake/drawing..');
  api.addThing('chapter1/sections/admissionprojects/snake/drawing/scenes/coworking');

  // Mixer
  api.addFile('chapter1/sections/mixer..');
  api.addFile('chapter1/sections/mixer/context');
  
  api.addThing('chapter1/sections/mixer/scenes/intercom');
  api.addFile('chapter1/sections/mixer/scenes/store');
  api.addFile('chapter1/sections/mixer/scenes/coworking');
  api.addFile('chapter1/sections/mixer/scenes/artstudio');

  api.addThing('chapter1/sections/mixer/scenes/gallerywest..');
  api.addFile('chapter1/sections/mixer/scenes/gallerywest/gallerywest-changepersonality');
  api.addFile('chapter1/sections/mixer/scenes/gallerywest/gallerywest-script');
  api.addFile('chapter1/sections/mixer/scenes/gallerywest/gallerywest-listener');
  api.addFile('chapter1/sections/mixer/scenes/gallerywest/retro');

  api.addFile('chapter1/sections/mixer/scenes/participants/participant');
  api.addFile('chapter1/sections/mixer/scenes/participants/ace');
  api.addFile('chapter1/sections/mixer/scenes/participants/ty');
  api.addFile('chapter1/sections/mixer/scenes/participants/saanvi');
  api.addFile('chapter1/sections/mixer/scenes/participants/mae');
  api.addFile('chapter1/sections/mixer/scenes/participants/lisa');
  api.addFile('chapter1/sections/mixer/scenes/participants/jaxx');

  api.addThing('chapter1/sections/mixer/items/marker');
  api.addFile('chapter1/sections/mixer/items/stickers');
  api.addFile('chapter1/sections/mixer/items/nametag');
  api.addFile('chapter1/sections/mixer/items/answer');

  api.addFile('chapter1/sections/mixer/icebreakers..');
  api.addFile('chapter1/sections/mixer/icebreakers/answeraction');
  api.addServerFile('chapter1/sections/mixer/icebreakers/subscriptions');
});
