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
  'quill-delta': '5.1.0'
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
  api.addClientComponent('component/article-client/article');

  api.addFile('article..');

  api.addClientFile('article/blots-client/header..');
  api.addClientFile('article/blots-client/customclass..');
  api.addClientUnstyledComponent('article/blots-client/tableofcontents..');

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
