Package.describe({
  name: 'retronator:retronator-hq',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'color-thief-standalone': '1.0.3'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:retronator');
  api.use('retronator:retronator-store');
  api.use('retronator:retronator-blog');
  api.use('retronator:pixelartacademy-cast');

  api.export('Retronator');

  api.addFile('hq');

  // Adventure

  api.addFile('adventure/adventure');

  // Actors

  api.addFile('actors/actors');
  api.addFile('actors/operator');
  api.addFile('actors/aeronaut');
  api.addFile('actors/burra');
  api.addFile('actors/corinne');
  api.addFile('actors/retro');
  api.addFile('actors/shelley');
  api.addFile('actors/alexandra');

  // Items

  api.addFile('items/items');

  api.addFile('items/components/components');
  api.addFile('items/components/stripe/stripe');

  api.addThing('items/elevatorbutton/elevatorbutton');
  api.addThingComponent('items/shoppingcart/shoppingcart');
  api.addFile('items/shoppingcart/shoppingcart-user');
  api.addFile('items/shoppingcart/shoppingcart-character');
  api.addComponent('items/prospectus/prospectus');
  api.addComponent('items/receipt/receipt');
  
  api.addFile('items/account/account');
  api.addFile('items/keycard/keycard');

  api.addThingComponent('items/operatorlink/operatorlink');

  api.addComponent('items/daily/daily');
  api.addComponent('items/daily/theme');
  api.addStyledFile('items/daily/theme-headlines');
  api.addFile('items/daily/theme-frontpage');
  api.addFile('items/daily/theme-stream');

  // Scenes
  
  api.addFile('scenes/scenes');
  
  api.addThing('scenes/intercom');
  api.addThing('scenes/shelley');
  api.addFile('scenes/inventory');

  // Locations

  api.addThing('basement1/basement/basement');

  api.addFile('elevator/elevator');
  api.addThing('elevator/numberpad');

  api.addFile('floor1/cafe/cafe');
  api.addFile('floor1/cafe/artworks');
  api.addScript('floor1/cafe/burra');
  api.addScript('floor1/cafe/burra-character');

  api.addFile('floor1/coworking/coworking');

  api.addThing('floor2/store/store');
  api.addFile('floor2/store/retro');
  api.addScript('floor2/store/store-character');

  api.addComponent('floor2/store/display/display');
  api.addComponent('floor2/store/shelf/shelf');
  api.addFile('floor2/store/shelf/shelf-game');
  api.addFile('floor2/store/shelf/shelf-upgrades');
  api.addFile('floor2/store/shelf/shelf-pixel');
  api.addThing('floor2/store/shelf/shelves');

  api.addFile('floor2/store/table/table');
  api.addFile('floor2/store/table/item/item');
  api.addFile('floor2/store/table/item/item-createtextscript');
  api.addStyledFile('floor2/store/table/item/photos');
  api.addStyledFile('floor2/store/table/item/article');
  api.addStyledFile('floor2/store/table/item/video');
  api.addStyledFile('floor2/store/table/item/link');
  api.addStyledFile('floor2/store/table/item/answer');
  api.addStyledFile('floor2/store/table/item/audio');
  api.addFile('floor2/store/table/item/chat');
  api.addFile('floor2/store/table/item/quote');

  api.addFile('floor2/bookshelves/bookshelves');

  api.addFile('floor3/gallery/galleryeast');
  api.addFile('floor3/gallery/gallerywest');

  api.addThing('floor4/artstudio/artstudio');
  
  // Pages
  
  api.addFile('pages/pages');
});
