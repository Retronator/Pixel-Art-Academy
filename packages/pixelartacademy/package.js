Package.describe({
  name: 'retronator:pixelartacademy',
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
  api.imply('retronator:landsofillusions');

  api.export('PixelArtAcademy');

  api.addFiles('pixelartacademy.coffee');

  // Layouts

  api.addFiles('layouts/layouts.coffee');

  api.addFiles('layouts/alphaaccess/alphaaccess.coffee');
  api.addFiles('layouts/alphaaccess/alphaaccess.html');

  api.addFiles('layouts/playeraccess/playeraccess.coffee');
  api.addFiles('layouts/playeraccess/playeraccess.html');

  api.addFiles('layouts/adminaccess/adminaccess.coffee');

  // Pages

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.coffee');

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
