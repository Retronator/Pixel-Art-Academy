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
  api.use('retronator:artificialengines-twitter');
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
  api.addFiles('submission/migrations/0002-converttohttps.coffee', 'server');

  // Pages
  api.addFile('pages/pages');

  api.addFile('pages/components/components');
  api.addComponent('pages/components/themebanner/themebanner');
  api.addStyleImport('pages/style/style');

  api.addComponent('pages/home/home');
  api.addServerFile('pages/home/subscriptions');
  api.addComponent('pages/home/layout/layout');
  api.addComponent('pages/home/header/header');
  api.addComponent('pages/home/navigation/navigation');
  api.addComponent('pages/home/artworkcaption/artworkcaption');

  api.addComponent('pages/about/about');

  api.addComponent('pages/yearreview/yearreview');

  api.addFile('pages/yearreview/helpers');

  api.addFile('pages/yearreview/years/years');
  api.addFile('pages/yearreview/years/year2016');
  api.addFile('pages/yearreview/years/year2017');
  api.addFile('pages/yearreview/years/year2018');
  api.addFile('pages/yearreview/years/year2019');
  api.addFile('pages/yearreview/years/year2020');

  api.addComponent('pages/yearreview/layout/layout');

  api.addFile('pages/yearreview/components/components');
  api.addComponent('pages/yearreview/components/stream/stream');
  api.addComponent('pages/yearreview/components/calendar/calendar');
  api.addFile('pages/yearreview/components/calendar/provider');
  api.addComponent('pages/yearreview/components/navigation/navigation');
  api.addComponent('pages/yearreview/components/header/header');
  api.addComponent('pages/yearreview/components/footer/footer');
  api.addFile('pages/yearreview/components/mixins/mixins');
  api.addFile('pages/yearreview/components/mixins/infinitescroll');

  api.addFile('pages/yearreview/themes/themescalendarprovider');
  api.addServerFile('pages/yearreview/themes/subscriptions');

  api.addComponent('pages/yearreview/artworks/artworks');
  api.addServerFile('pages/yearreview/artworks/subscriptions');

  api.addComponent('pages/yearreview/artists/artists');
  api.addServerFile('pages/yearreview/artists/subscriptions');

  api.addComponent('pages/yearreview/artist/artist');
  api.addFile('pages/yearreview/artist/calendarprovider');
  api.addServerFile('pages/yearreview/artist/subscriptions');

  api.addComponent('pages/yearreview/day/day');
  api.addServerFile('pages/yearreview/day/subscriptions');

  api.addComponent('pages/yearreview/about/about');

  api.addUnstyledComponent('pages/admin/admin');

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
