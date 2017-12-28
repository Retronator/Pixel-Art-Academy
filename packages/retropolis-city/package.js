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
  
  // Pages
  api.addFile('pages..');

  api.addComponent('pages/layout..');
  api.addComponent('pages/home..');

  api.addFile('pages/academyofart..');
  api.addComponent('pages/academyofart/layout..');
  api.addComponent('pages/academyofart/academy..');
  api.addComponent('pages/academyofart/programs..');
  api.addComponent('pages/academyofart/campuslife..');
  api.addComponent('pages/academyofart/admissions..');
  api.addComponent('pages/academyofart/application..');
});
