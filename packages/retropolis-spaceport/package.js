Package.describe({
  name: 'retronator:retropolis-spaceport',
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
  api.use('retronator:retropolis');
  api.use('retronator:landsofillusions');

  api.export('Retropolis');

  api.addFiles('spaceport.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/terrace/terrace.coffee');
  api.addFiles('locations/terrace/terrace.html');
  api.addFiles('locations/terrace/terrace.styl');

});
