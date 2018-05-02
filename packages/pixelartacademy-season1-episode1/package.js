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
  api.use('retronator:pixelartacademy-season1');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:landsofillusions');
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

  api.addServerFile('chapter1/migrations/0000-admissionapplication');

  api.addFile('chapter1/events..');
  api.addFile('chapter1/events/applicationaccepted');

  api.addFile('chapter1/items..');
  api.addFile('chapter1/items/applicationemail');
  api.addFile('chapter1/items/admissionemail');

  api.addFile('chapter1/scenes/inbox');
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
  api.addFile('chapter1/groups/sanfranciscofriends');
  api.addThing('chapter1/groups/sanfranciscofriends-conversation');
  api.addFile('chapter1/groups/family');

  api.addThing('chapter1/groups/admissionsstudygroup..');
  api.addFile('chapter1/groups/admissionsstudygroup/coworking');

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
  api.addThing('chapter1/sections/postpixelboy/scenes/store');
});
