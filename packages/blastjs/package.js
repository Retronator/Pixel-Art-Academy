Package.describe({
  name: 'blastjs',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'Blast text apart to make it manipulable.',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function (api, where) {
  api.versionsFrom("1.0");
  api.use('jquery');
  api.addFiles('jquery.blast.min.js', 'client');
});
