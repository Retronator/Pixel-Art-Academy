Package.describe({
  name: 'retronator:app',
  version: '0.44.0',
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
  api.use('retronator:landsofillusions');

  // Routing portion, fork from force-ssl.
  api.use('webapp', 'server');
  
  // Make sure we come after livedata, so we load after the sockjs server has been instantiated.
  api.use('ddp', 'server');

  api.addServerFile('routing-server');

  // Add global user meld (it needs to be in top-level package to have access to all documents).
  api.use('splendido:accounts-meld@1.3.1');
  api.addServerFile('accountsmeld-server');

  // Add other files.
  api.addUnstyledComponent('app');

  // Layouts

  api.addFile('layouts/layouts');
  api.addUnstyledComponent('layouts/adminaccess/adminaccess');
  api.addUnstyledComponent('layouts/useraccess/useraccess');
  api.addUnstyledComponent('layouts/publicaccess/publicaccess');
});
