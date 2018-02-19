Package.describe({
  name: 'retronator:illustrapedia',
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
  api.use('retronator:artificialengines');
  api.use('retronator:retronator-accounts');

  api.export('Illustrapedia');
  
  api.addFile('illustrapedia');

  api.addFile('interest..');
  api.addServerFile('interest/methods-server');
  api.addServerFile('interest/subscriptions');

  // Pages

  api.addFile('pages/pages');

  // Admin

  api.addUnstyledComponent('pages/admin..');

  api.addFile('pages/admin/interests..');
  api.addUnstyledComponent('pages/admin/interests/interest');
});
