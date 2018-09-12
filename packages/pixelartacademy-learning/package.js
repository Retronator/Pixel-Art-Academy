Package.describe({
  name: 'retronator:pixelartacademy-learning',
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
  api.use('retronator:pixelartacademy');
  api.use('retronator:illustrapedia');

  api.export('PixelArtAcademy');

  api.addFile('learning');
  
  api.addFile('goal..');
  api.addFile('task..');

  api.addFile('task/tasks/automatic');
  api.addFile('task/tasks/manual');
  api.addFile('task/tasks/upload');
  api.addFile('task/tasks/survey');

  api.addFile('task/entry..');
  api.addFile('task/entry/methods');
  api.addServerFile('task/entry/subscriptions');
});
