Package.describe({
  name: 'retronator:app',
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
  api.use('retronator:retronator');
  api.use('retronator:artificialengines');
  api.use('retronator:accounts');
  api.use('retronator:landsofillusions');
  api.use('retronator:hq');
  api.use('retronator:store');

  /*api.use('retronator:construct');
  api.use('retronator:pixelboy');
  api.use('retronator:practice');
  api.use('retronator:pixeldailies');*/

  // All Retronator websites run over SSL.
  api.use('keyvan:my-force-ssl');

  api.addFiles('app.html');
  api.addFiles('app.coffee');
});
