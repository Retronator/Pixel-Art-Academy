Package.describe({
  name: 'retronator:fatamorgana',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: 'Application GUI built with Artificial Mirage.',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/Retronator/Landsofillusions.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('FataMorgana');

  api.addFile('fatamorgana');
  api.addComponent('interface');
  api.addFile('interface-shortcuts');
  api.addFile('action');
  api.addFile('tool');

  api.addComponent('area');
  api.addFile('areas/applicationarea');
  api.addFile('areas/dockedarea');
  api.addFile('areas/floatingarea');

  api.addFile('view');
  api.addComponent('views/splitview..');
  api.addComponent('views/tabbedview..');
  api.addComponent('views/menu..');
  api.addComponent('views/menu/dropdown');
  api.addComponent('views/toolbox..');
});
