Package.describe({
  name: 'pixelartacademy',
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
  api.use('kadira:flow-router');
  api.use('retronator:landsofillusions');
  api.use('alanning:roles');

  api.imply('retronator:landsofillusions');

  api.export('PixelArtAcademy');

  api.addFiles('pixelartacademy.html');
  api.addFiles('pixelartacademy.styl');
  api.addFiles('pixelartacademy.coffee');
  api.addFiles('server.coffee', 'server');

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.coffee');

  api.addFiles('pages/login/login.html');
  api.addFiles('pages/login/login.coffee');

  api.addFiles('pages/admin/admin.html');
  api.addFiles('pages/admin/admin.coffee');
  api.addFiles('pages/admin/components/components.coffee');
  api.addFiles('pages/admin/components/adminpage/adminpage.coffee');
  api.addFiles('pages/admin/components/adminpage/adminpage.html');
  api.addFiles('pages/admin/components/adminpage/adminpage.styl');
  api.addFiles('pages/admin/components/index/index.coffee');
  api.addFiles('pages/admin/components/index/index.html');
  api.addFiles('pages/admin/components/index/index.styl');
  api.addFiles('pages/admin/components/document/document.coffee');

  api.addFiles('character/methods.coffee', 'server');
});
