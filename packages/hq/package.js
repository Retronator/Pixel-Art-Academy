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
  api.addAssets('hq.script', ['client', 'server']);

  // Actors
  api.addFiles('actors/actors.coffee');

  api.addFiles('actors/elevatorbutton.coffee');
  api.addAssets('actors/elevatorbutton.script', ['client', 'server']);

  api.addFiles('actors/operator.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/1stfloor/entrance/entrance.coffee');
  api.addFiles('locations/1stfloor/entrance/sign.coffee');

  api.addFiles('locations/1stfloor/lobby/lobby.coffee');
  api.addAssets('locations/1stfloor/lobby/tablet.script', ['client', 'server']);

  api.addFiles('locations/1stfloor/lobby/display/display.coffee');
  api.addFiles('locations/1stfloor/lobby/display/display.html');
  api.addFiles('locations/1stfloor/lobby/display/display.styl');

  api.addFiles('locations/1stfloor/reception/reception.coffee');
  api.addAssets('locations/1stfloor/reception/burra.script', ['client', 'server']);

  api.addFiles('locations/1stfloor/restroom/restroom.coffee');

  api.addFiles('locations/1stfloor/gallery/gallery.coffee');

  api.addFiles('locations/elevator/elevator.coffee');
  api.addFiles('locations/elevator/numberpad.coffee');
  api.addAssets('locations/elevator/numberpad.script', ['client', 'server']);

  api.addFiles('locations/2ndfloor/steps/steps.coffee');

  api.addFiles('locations/2ndfloor/store/store.coffee');

  api.addFiles('locations/2ndfloor/checkout/checkout.coffee');
  api.addAssets('locations/2ndfloor/checkout/retro.script', ['client', 'server']);

  api.addFiles('locations/2ndfloor/store/shelf/shelf.coffee');
  api.addFiles('locations/2ndfloor/store/shelf/shelf.html');
  api.addFiles('locations/2ndfloor/store/shelf/shelf.styl');
  api.addFiles('locations/2ndfloor/store/shelf/shelf-preorders.coffee');

  api.addFiles('locations/3rdfloor/chillout/chillout.coffee');

  api.addFiles('locations/3rdfloor/ideagarden/ideagarden.coffee');

  api.addFiles('locations/3rdfloor/theater/theater.coffee');

  api.addFiles('locations/3rdfloor/landsofillusions/landsofillusions.coffee');
  api.addFiles('locations/3rdfloor/landsofillusions/methods-server.coffee', ['server']);
  api.addAssets('locations/3rdfloor/landsofillusions/operator.script', ['client', 'server']);

  api.addFiles('locations/3rdfloor/landsofillusions/hallway/hallway.coffee');
  api.addAssets('locations/3rdfloor/landsofillusions/hallway/operator.script', ['client', 'server']);

  api.addFiles('locations/3rdfloor/landsofillusions/cabin/cabin.coffee');
  api.addAssets('locations/3rdfloor/landsofillusions/cabin/operator.script', ['client', 'server']);

  api.addFiles('locations/4thfloor/studio/studio.coffee');

  api.addFiles('locations/4thfloor/studio/kitchen/kitchen.coffee');

  api.addFiles('locations/4thfloor/studio/hallway/hallway.coffee');

  api.addFiles('locations/4thfloor/studio/bathroom/bathroom.coffee');

  api.addFiles('locations/4thfloor/studio/bedroom/bedroom.coffee');
  
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

  api.addFiles('items/tablet/apps/prospectus/prospectus.coffee');
  api.addFiles('items/tablet/apps/prospectus/prospectus.html');
  api.addFiles('items/tablet/apps/prospectus/prospectus.styl');

  api.addFiles('items/tablet/apps/shoppingcart/shoppingcart.coffee');
  api.addFiles('items/tablet/apps/shoppingcart/shoppingcart.html');
  api.addFiles('items/tablet/apps/shoppingcart/shoppingcart.styl');

  api.addFiles('items/tablet/apps/shoppingcart/receipt/receipt.coffee');
  api.addFiles('items/tablet/apps/shoppingcart/receipt/receipt.html');
  api.addFiles('items/tablet/apps/shoppingcart/receipt/receipt.styl');

});
