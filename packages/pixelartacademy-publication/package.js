Package.describe({
  name: 'retronator:pixelartacademy-publication',
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
  'quill-delta': '4.2.2'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');

  api.export('PixelArtAcademy');

  api.addFile('publication');
  api.addFile('methods');
  api.addFile('subscriptions');

  api.addFile('part..');
  api.addFile('part/methods');
  api.addFile('part/subscriptions');

  api.addComponent('component..');

  api.addFile('article..');

  api.addClientComponent('article/blots-client/figure..');
  api.addClientComponent('article/blots-client/figure/image..');

  api.addFile('pages..');

  api.addUnstyledComponent('pages/admin..');

  api.addComponent('pages/admin/parts..');
  api.addComponent('pages/admin/parts/part');
  api.addClientComponent('pages/admin/parts/article-client/article');

  api.addComponent('pages/admin/publications..');
  api.addComponent('pages/admin/publications/publication');
});
