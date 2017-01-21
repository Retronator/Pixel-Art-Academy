Package.describe({
  name: 'retronator:pixelartacademy-pixeldailies',
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
  api.use('retronator:pixelartacademy');
	api.use('chfritz:easycron');
	
  api.export('PixelArtAcademy');

  api.addFiles('pixeldailies.coffee');

  // Immediately add the server file because it rewrites the PixelDailies class.
  api.addFiles('server.coffee', 'server');

  api.addFiles('theme/theme.coffee');
  api.addFiles('theme/subscriptions.coffee', 'server');
	api.addFiles('theme/migrations/0000-multiplehashtags.coffee', 'server');
	api.addFiles('theme/migrations/0001-datetotime.coffee', 'server');
	api.addFiles('theme/migrations/0002-reprocesstime.coffee', 'server');
	api.addFiles('theme/migrations/0003-hashtagstolowercase.coffee', 'server');

	api.addFiles('submission/submission.coffee');
	api.addFiles('submission/subscriptions.coffee', 'server');
	api.addFiles('submission/migrations/0000-reprocessimages.coffee', 'server');

	api.addFiles('calendar/themesprovider.coffee');

  api.addFiles('calendar/themecomponent.html');
  api.addFiles('calendar/themecomponent.coffee');
  api.addFiles('calendar/themecomponent.styl');
});
