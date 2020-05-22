Package.describe({
  name: 'retronator:pixelartacademy-items',
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
  api.use('retronator:pixelartacademy');

  api.export('PixelArtAcademy');

  api.addFile('items');
  
  api.addThing('bottle..');
  api.addFile('bottle/scene');

  api.addThing('kitchenknife..');
  api.addFile('kitchenknife/half');

  api.addFile('stilllifeitems..');
  api.addFile('stilllifeitems/scene');
  api.addFile('stilllifeitems/container');

  api.addFile('stilllifeitems/item..');
  api.addFile('stilllifeitems/item/avatar..');
  api.addFile('stilllifeitems/item/avatar/model');
  api.addClientFile('stilllifeitems/item/avatar/model-loader');
  api.addFile('stilllifeitems/item/avatar/proceduralmodel');
  api.addFile('stilllifeitems/item/avatar/box');
  api.addFile('stilllifeitems/item/avatar/cone');
  api.addFile('stilllifeitems/item/avatar/cylinder');
  api.addFile('stilllifeitems/item/avatar/sphere');

  api.addFile('stilllifeitems/items/primitives/cube');

  api.addFile('stilllifeitems/items/fruit/apple');
  api.addFile('stilllifeitems/items/fruit/apple-green');
  api.addFile('stilllifeitems/items/fruit/kiwi');
  api.addFile('stilllifeitems/items/fruit/banana');
  api.addFile('stilllifeitems/items/fruit/mango');
  api.addFile('stilllifeitems/items/fruit/blueberry');
  api.addFile('stilllifeitems/items/fruit/orange');
  api.addFile('stilllifeitems/items/fruit/raspberry');
  api.addFile('stilllifeitems/items/fruit/watermelon');

  api.addFile('stilllifeitems/items/tableware/bowl');
  api.addFile('stilllifeitems/items/tableware/bowl-large');
});
