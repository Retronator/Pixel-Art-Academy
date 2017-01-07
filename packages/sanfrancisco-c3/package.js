Package.describe({
  name: 'retronator:sanfrancisco-c3',
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
  api.use('retronator:sanfrancisco');
  api.use('retronator:landsofillusions');

  api.export('SanFrancisco');

  api.addFiles('c3.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/c3.coffee');
  api.addFiles('locations/entrance/entrance.coffee');
  api.addFiles('locations/lobby/lobby.coffee');
  
});
