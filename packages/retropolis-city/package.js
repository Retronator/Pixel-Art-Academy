Package.describe({
  name: 'retronator:retropolis-city',
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
  api.use('retronator:retropolis');

  api.export('Retropolis');

  api.addFile('city');

  // Layouts
  api.addFile('layouts/layouts');
  api.addComponent('layouts/city/city');

  // Pages
  api.addFile('pages/pages');
  api.addComponent('pages/home/home');
});
