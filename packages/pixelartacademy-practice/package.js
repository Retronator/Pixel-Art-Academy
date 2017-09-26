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

  api.addFile('practice');
  api.addServerFile('server');
  api.addClientFile('client');

  api.addFile('checkin/checkin');
  api.addFile('checkin/methods');
  api.addServerFile('checkin/methods-server');
  api.addServerFile('checkin/subscriptions');
  api.addServerFile('checkin/migrations/0000-renamecollection');
  api.addServerFile('checkin/migrations/0001-characterreferencefieldsupdate');
  api.addServerFile('checkin/migrations/0002-removecharacternamefield');

  api.addFile('importeddata/importeddata');
  api.addServerFile('importeddata/checkin-server/checkin');
  api.addServerFile('importeddata/checkin-server/migrations/0000-renamecollection');

  api.addFile('pages/pages');

  api.addUnstyledComponent('pages/extractimagesfromposts/extractimagesfromposts');
  api.addServerFile('pages/extractimagesfromposts/methods-server');

  api.addComponent('pages/importcheckins/importcheckins');
  api.addServerFile('pages/importcheckins/methods-server');

});
