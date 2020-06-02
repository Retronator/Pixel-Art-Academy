Package.describe({
  name: 'retronator:retronator-blog',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'node-webshot': '1.0.4',
  's3-streaming-upload': '0.2.3'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartdatabase');
  api.use('chfritz:easycron');
  api.use('http');
  api.use('webapp', 'server');

  api.export('Retronator');

  api.addFile('blog');

  // Immediately add the server file because it rewrites the Blog class.
  api.addServerFile('server');
  api.addServerFile('server-processpost');
  api.addServerFile('server-renderwebsitepreview');
  
  // Post

  api.addFile('post/post');
  api.addServerFile('post/subscriptions');
  api.addServerFile('post/methods-server');

  api.addServerFile('methods-server');
  
  // Website

  api.addFile('website/website');
  api.addServerFile('website/methods-server');

  // Pages
  api.addFile('pages/pages');

  api.addUnstyledComponent('pages/admin/admin');

  api.addUnstyledComponent('pages/admin/scripts/scripts');
  api.addServerFile('pages/admin/scripts/methods-server/processposthistory');
});
