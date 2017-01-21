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

Package.onUse(function(api) {
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-pixelboy');

  api.use('edgee:slingshot');
  api.use('jparker:crypto-aes');
  api.use('http');

  api.export('PixelArtAcademy');

  api.addFiles('practice.coffee');
  api.addFiles('server.coffee', 'server');
  api.addFiles('client.coffee', 'client');

  api.addFiles('checkin/checkin.coffee');
  api.addFiles('checkin/methods.coffee');
  api.addFiles('checkin/methods-server.coffee', 'server');
  api.addFiles('checkin/subscriptions.coffee', 'server');

  api.addFiles('calendar/checkinsprovider.coffee');

  api.addFiles('calendar/checkincomponent.html');
  api.addFiles('calendar/checkincomponent.coffee');
  api.addFiles('calendar/checkincomponent.styl');

  api.addFiles('importeddata/importeddata.coffee');
  api.addFiles('importeddata/checkin.coffee', 'server');

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/extractimagesfromposts/extractimagesfromposts.coffee');
  api.addFiles('pages/extractimagesfromposts/extractimagesfromposts.html');

  api.addFiles('pages/importcheckins/importcheckins.coffee');
  api.addFiles('pages/importcheckins/importcheckins.html');
  api.addFiles('pages/importcheckins/importcheckins.styl');
  api.addFiles('pages/importcheckins/methods.coffee', 'server');

});
