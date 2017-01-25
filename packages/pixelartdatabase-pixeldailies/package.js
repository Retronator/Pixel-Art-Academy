Package.describe({
  name: 'retronator:pixelartdatabase-pixeldailies',
  version: '0.2.0',
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
  api.use('retronator:pixelartdatabase');
	api.use('chfritz:easycron');
	
  api.export('PixelArtDatabase');

  api.addFiles('pixeldailies.coffee');

  // Immediately add the server file because it rewrites the PixelDailies class.
  api.addFiles('server.coffee', 'server');
  api.addFiles('server-processtweet.coffee', 'server');
  api.addFiles('server-padb.coffee', 'server');

  api.addFiles('theme/theme.coffee');
  api.addFiles('theme/subscriptions.coffee', 'server');

	api.addFiles('theme/migrations/0000-multiplehashtags.coffee', 'server');
	api.addFiles('theme/migrations/0001-datetotime.coffee', 'server');
	api.addFiles('theme/migrations/0002-reprocesstime.coffee', 'server');
	api.addFiles('theme/migrations/0003-hashtagstolowercase.coffee', 'server');
  api.addFiles('theme/migrations/0004-renamecollection.coffee', 'server');

	api.addFiles('submission/submission.coffee');
	api.addFiles('submission/subscriptions.coffee', 'server');

	api.addFiles('submission/migrations/0000-reprocessimages.coffee', 'server');
  api.addFiles('submission/migrations/0001-renamecollection.coffee', 'server');

  // Pages
  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.styl');
  api.addFiles('pages/home/home.coffee');

  api.addFiles('pages/top2016/top2016.coffee');
  api.addFiles('pages/top2016/top2016.html');
  api.addFiles('pages/top2016/top2016.styl');

  api.addFiles('pages/top2016/layout/layout.html');
  api.addFiles('pages/top2016/layout/layout.styl');
  api.addFiles('pages/top2016/layout/layout.coffee');

  api.addFiles('pages/top2016/components/components.coffee');

  api.addFiles('pages/top2016/components/stream/stream.html');
  api.addFiles('pages/top2016/components/stream/stream.styl');
  api.addFiles('pages/top2016/components/stream/stream.coffee');

  api.addFiles('pages/top2016/components/navigation/navigation.html');
  api.addFiles('pages/top2016/components/navigation/navigation.styl');
  api.addFiles('pages/top2016/components/navigation/navigation.coffee');

  api.addFiles('pages/top2016/components/mixins/mixins.coffee');
  api.addFiles('pages/top2016/components/mixins/infinitescroll.coffee');

  api.addFiles('pages/top2016/artworks/artworks.html');
  api.addFiles('pages/top2016/artworks/artworks.styl');
  api.addFiles('pages/top2016/artworks/artworks.coffee');
  api.addFiles('pages/top2016/artworks/subscriptions.coffee', 'server');

  api.addFiles('pages/admin/admin.html');
  api.addFiles('pages/admin/admin.coffee');

  api.addFiles('pages/admin/scripts/scripts.coffee');
  api.addFiles('pages/admin/scripts/scripts.html');
  api.addFiles('pages/admin/scripts/methods-server/archiveallsubmissions.coffee', 'server');
  api.addFiles('pages/admin/scripts/methods-server/rematchmissingthemes.coffee', 'server');

});
