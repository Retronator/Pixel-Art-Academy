Package.describe({
  name: 'retronator:pixelartacademy-studyguide',
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
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:illustrapedia');

  api.export('PixelArtAcademy');

  api.addFile('studyguide');
  api.addFile('studyguide-goals');
  api.addFile('studyguide-tasks');

  api.addFile('activity..');
  api.addClientFile('activity/activity-client');
  api.addServerFile('activity/server');
  api.addFile('activity/methods');
  api.addServerFile('activity/subscriptions');

  api.addFile('pages..');
  api.addUnstyledComponent('pages/admin..');

  api.addComponent('pages/admin/activities..');
  api.addComponent('pages/admin/activities/activity');
  api.addComponent('pages/admin/activities/task');

});
