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
  api.use('kadira:blaze-layout');
  api.use('peerlibrary:blaze-layout-component');
  api.use('retronator:landsofillusions');
  api.use('alanning:roles');
  api.use('accounts-password');

  api.imply('retronator:landsofillusions');

  api.export('PixelArtAcademy');

  api.addFiles('pixelartacademy.html');
  api.addFiles('pixelartacademy.styl');
  api.addFiles('pixelartacademy.coffee');
  api.addFiles('server.coffee', 'server');

  api.addFiles('layouts/layouts.coffee');

  api.addFiles('layouts/alphaaccess/alphaaccess.coffee');
  api.addFiles('layouts/alphaaccess/alphaaccess.html');

  api.addFiles('layouts/localaccess/localaccess.coffee');
  api.addFiles('layouts/localaccess/localaccess.html');

  api.addFiles('layouts/adminaccess/adminaccess.coffee');
  api.addFiles('layouts/adminaccess/adminaccess.html');

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.coffee');

  api.addFiles('pages/login/login.html');
  api.addFiles('pages/login/login.coffee');

  api.addFiles('pages/intro/intro.html');
  api.addFiles('pages/intro/intro.styl');
  api.addFiles('pages/intro/intro.coffee');
  api.addFiles('pages/intro/methods-server.coffee', 'server');

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
});
