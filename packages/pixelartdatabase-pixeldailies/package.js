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
  api.use('http');

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
  api.addFiles('submission/migrations/0002-converttohttps.coffee', 'server');

  // Pages
  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.styl');
  api.addFiles('pages/home/home.coffee');

  api.addFiles('pages/yearreview/yearreview.coffee');
  api.addFiles('pages/yearreview/yearreview.html');
  api.addFiles('pages/yearreview/yearreview.styl');
  api.addFiles('pages/yearreview/yearreview.import.styl', ['client'], {isImport: true});

  api.addFiles('pages/yearreview/helpers.coffee');

  api.addFile('pages/yearreview/years/years');
  api.addFile('pages/yearreview/years/year2016');
  api.addFile('pages/yearreview/years/year2017');

  api.addFiles('pages/yearreview/layout/layout.html');
  api.addFiles('pages/yearreview/layout/layout.styl');
  api.addFiles('pages/yearreview/layout/layout.coffee');

  api.addFiles('pages/yearreview/components/components.coffee');

  api.addFiles('pages/yearreview/components/stream/stream.html');
  api.addFiles('pages/yearreview/components/stream/stream.styl');
  api.addFiles('pages/yearreview/components/stream/stream.coffee');

  api.addFiles('pages/yearreview/components/calendar/calendar.html');
  api.addFiles('pages/yearreview/components/calendar/calendar.styl');
  api.addFiles('pages/yearreview/components/calendar/calendar.coffee');
  api.addFiles('pages/yearreview/components/calendar/provider.coffee');

  api.addFiles('pages/yearreview/components/navigation/navigation.html');
  api.addFiles('pages/yearreview/components/navigation/navigation.styl');
  api.addFiles('pages/yearreview/components/navigation/navigation.coffee');

  api.addFiles('pages/yearreview/components/themebanner/themebanner.html');
  api.addFiles('pages/yearreview/components/themebanner/themebanner.styl');
  api.addFiles('pages/yearreview/components/themebanner/themebanner.coffee');

  api.addFiles('pages/yearreview/components/header/header.html');
  api.addFiles('pages/yearreview/components/header/header.styl');
  api.addFiles('pages/yearreview/components/header/header.coffee');
  
  api.addFiles('pages/yearreview/components/footer/footer.html');
  api.addFiles('pages/yearreview/components/footer/footer.styl');
  api.addFiles('pages/yearreview/components/footer/footer.coffee');

  api.addFiles('pages/yearreview/components/mixins/mixins.coffee');
  api.addFiles('pages/yearreview/components/mixins/infinitescroll.coffee');

  api.addFiles('pages/yearreview/themes/themescalendarprovider.coffee');
  api.addFiles('pages/yearreview/themes/subscriptions.coffee', 'server');

  api.addFiles('pages/yearreview/artworks/artworks.html');
  api.addFiles('pages/yearreview/artworks/artworks.styl');
  api.addFiles('pages/yearreview/artworks/artworks.coffee');
  api.addFiles('pages/yearreview/artworks/subscriptions.coffee', 'server');

  api.addFiles('pages/yearreview/artists/artists.html');
  api.addFiles('pages/yearreview/artists/artists.styl');
  api.addFiles('pages/yearreview/artists/artists.coffee');
  api.addFiles('pages/yearreview/artists/subscriptions.coffee', 'server');

  api.addFiles('pages/yearreview/artist/artist.html');
  api.addFiles('pages/yearreview/artist/artist.styl');
  api.addFiles('pages/yearreview/artist/artist.coffee');
  api.addFiles('pages/yearreview/artist/calendarprovider.coffee');
  api.addFiles('pages/yearreview/artist/subscriptions.coffee', 'server');

  api.addFiles('pages/yearreview/day/day.html');
  api.addFiles('pages/yearreview/day/day.styl');
  api.addFiles('pages/yearreview/day/day.coffee');
  api.addFiles('pages/yearreview/day/subscriptions.coffee', 'server');

  api.addFiles('pages/yearreview/about/about.html');
  api.addFiles('pages/yearreview/about/about.styl');
  api.addFiles('pages/yearreview/about/about.coffee');

  api.addFiles('pages/admin/admin.html');
  api.addFiles('pages/admin/admin.coffee');

  api.addFile('pages/admin/scripts/scripts');
  api.addHtml('pages/admin/scripts/scripts');
  api.addServerFile('pages/admin/scripts/methods-server/processtweethistory');
  api.addServerFile('pages/admin/scripts/methods-server/archiveallsubmissions');
  api.addServerFile('pages/admin/scripts/methods-server/reprocesssubmissions');
  api.addServerFile('pages/admin/scripts/methods-server/updatethemesubmissions');
  api.addServerFile('pages/admin/scripts/methods-server/reprocessprofiles');
  api.addServerFile('pages/admin/scripts/methods-server/updateuserstatistics');
  api.addServerFile('pages/admin/scripts/methods-server/retiremissingsubmissions');
});
