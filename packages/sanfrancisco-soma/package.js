Package.describe({
  name: 'retronator:sanfrancisco-soma',
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

  api.addFile('soma');

  // Locations

  api.addFile('caltrain/caltrain');
  api.addFile('4thking/4thking');
  api.addFile('moscone/moscone');
  api.addFile('2nd/2nd');
  api.addFile('2nd/retronatorhq');
  api.addFile('2nd/artistsign');
});
