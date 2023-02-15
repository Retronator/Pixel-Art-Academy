Package.describe({
  name: 'retronator:retronator-identity',
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

  // Typography

  api.addCss('typography..');
  api.addStyleImport('typography..');

  // Styles

  api.addStyleImport('style..');
  api.addStyleImport('style/atari2600');
  api.addStyleImport('style/cursors');
  api.addStyle('style/cursors');
  api.addStyle('style/defaults');
});
