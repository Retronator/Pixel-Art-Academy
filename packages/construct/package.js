Package.describe({
  name: 'retronator:construct',
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

  api.export('LandsOfIllusions');

  api.addFiles('construct.coffee');

  // Pages

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/login/login.html');
  api.addFiles('pages/login/login.coffee');

  api.addFiles('pages/account/account.html');
  api.addFiles('pages/account/account.styl');
  api.addFiles('pages/account/account.coffee');
});
