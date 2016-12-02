Package.describe({
  name: 'retronator:hq',
  version: '0.0.1',
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
  api.use('retronator:retronator');
  api.use('retronator:store');
  api.use('retronator:cast');

  api.export('Retronator');

  api.addFiles('hq.coffee');

  // Actors
  api.addFiles('actors/actors.coffee');

  api.addFiles('actors/elevatorbutton.coffee');
  api.addAssets('actors/elevatorbutton.script', ['client', 'server']);

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/entrance/entrance.coffee');
  api.addFiles('locations/entrance/sign.coffee');

  api.addFiles('locations/lobby/lobby.coffee');
  api.addAssets('locations/lobby/tablet.script', ['client', 'server']);

  api.addFiles('locations/lobby/display/display.coffee');
  api.addFiles('locations/lobby/display/display.html');
  api.addFiles('locations/lobby/display/display.styl');

  api.addFiles('locations/reception/reception.coffee');
  api.addAssets('locations/reception/burra.script', ['client', 'server']);

  api.addFiles('locations/elevator/elevator.coffee');
  api.addFiles('locations/elevator/numberpad.coffee');
  api.addAssets('locations/elevator/numberpad.script', ['client', 'server']);

  api.addFiles('locations/store/store.coffee');
  api.addFiles('locations/store/checkout/checkout.coffee');
  api.addAssets('locations/store/checkout/retro.script', ['client', 'server']);

  api.addFiles('locations/store/checkout/receipt/receipt.coffee');
  api.addFiles('locations/store/checkout/receipt/receipt.html');
  api.addFiles('locations/store/checkout/receipt/receipt.styl');

  api.addFiles('locations/store/shelf/shelf.coffee');
  api.addFiles('locations/store/shelf/shelf.html');
  api.addFiles('locations/store/shelf/shelf.styl');
  api.addFiles('locations/store/shelf/shelf-preorders.coffee');

  api.addFiles('locations/store/shoppingcart/shoppingcart.coffee');
  api.addFiles('locations/store/shoppingcart/shoppingcart.html');
  api.addFiles('locations/store/shoppingcart/shoppingcart.styl');

  // Items

  api.addFiles('items/items.coffee');

  api.addFiles('items/wallet/wallet.coffee');
  api.addFiles('items/wallet/wallet.html');
  api.addFiles('items/wallet/wallet.styl');

  api.addFiles('items/tablet/tablet.coffee');
  api.addFiles('items/tablet/tablet.html');
  api.addFiles('items/tablet/tablet.styl');

  api.addFiles('items/tablet/os/os.coffee');
  api.addFiles('items/tablet/os/os.html');
  api.addFiles('items/tablet/os/os.styl');
  
  api.addFiles('items/tablet/os/app.coffee');
  api.addFiles('items/tablet/os/app.styl');

  api.addFiles('items/tablet/apps/apps.coffee');

  api.addFiles('items/tablet/apps/menu/menu.coffee');
  api.addFiles('items/tablet/apps/menu/menu.html');
  api.addFiles('items/tablet/apps/menu/menu.styl');

  api.addFiles('items/tablet/apps/welcome/welcome.coffee');
  api.addFiles('items/tablet/apps/welcome/welcome.html');
  api.addFiles('items/tablet/apps/welcome/welcome.styl');

  api.addFiles('items/tablet/apps/account/account.coffee');
  api.addFiles('items/tablet/apps/account/account.html');
  api.addFiles('items/tablet/apps/account/account.styl');

  api.addFiles('items/tablet/apps/manual/manual.coffee');
  api.addFiles('items/tablet/apps/manual/manual.html');
  api.addFiles('items/tablet/apps/manual/manual.styl');
});
