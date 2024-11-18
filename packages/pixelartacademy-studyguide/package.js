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

Npm.depends({
  'quill-delta': '5.1.0'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:illustrapedia');

  api.export('PixelArtAcademy');

  api.addFile('studyguide');
  api.addFile('studyguide-goals');
  api.addFile('studyguide-tasks');

  api.addFile('global');

  api.addFile('article..');

  api.addClientComponent('article/blots-client/figure..');
  api.addClientComponent('article/blots-client/figure/image..');

  api.addClientFile('article/blots-client/practicesection..');
  api.addStyle('article/blots-client/practicesection..');

  api.addClientFile('article/blots-client/task..');
  api.addStyle('article/blots-client/task..');
  api.addClientComponent('article/blots-client/task/prerequisiteswarning..');
  api.addClientComponent('article/blots-client/task/reading..');
  api.addClientComponent('article/blots-client/task/upload..');

  api.addStyle('style/article');

  api.addFile('activity..');
  api.addClientFile('activity/activity-client');
  api.addServerFile('activity/server');
  api.addFile('activity/methods');
  api.addServerFile('activity/subscriptions');

  api.addFile('book..');
  api.addFile('book/methods');
  api.addServerFile('book/subscriptions');

  api.addFile('pages..');

  api.addComponent('pages/layout..');

  api.addComponent('pages/home..');

  api.addComponent('pages/home/menu..');
  api.addComponent('pages/home/menu/items..');

  api.addComponent('pages/home/activities..');
  api.addComponent('pages/home/studyplan..');
  api.addComponent('pages/home/about..');

  api.addComponent('pages/home/submissions..');
  api.addComponent('pages/home/submissions/picture..');

  api.addComponent('pages/home/book..');
  api.addClientComponent('pages/home/book/article-client/article');

  api.addUnstyledComponent('pages/admin..');

  api.addComponent('pages/admin/activities..');
  api.addComponent('pages/admin/activities/activity');
  api.addComponent('pages/admin/activities/task');
  api.addClientComponent('pages/admin/activities/article-client/article');

  api.addComponent('pages/admin/books..');
  api.addComponent('pages/admin/books/book');
});
