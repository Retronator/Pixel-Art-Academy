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

  api.addFile('pixelartacademy');

  // Layouts

  api.addFile('layouts/layouts');

  api.addUnstyledComponent('layouts/alphaaccess/alphaaccess');

  api.addUnstyledComponent('layouts/playeraccess/playeraccess');

  api.addFile('layouts/adminaccess/adminaccess');

  // Pages

  api.addFile('pages/pages');

  api.addFile('pages/admin/admin');
  api.addFile('pages/admin/components/components');
  api.addComponent('pages/admin/components/adminpage/adminpage');
  api.addComponent('pages/admin/components/index/index');
  api.addFile('pages/admin/components/document/document');

  api.addServerFile('character/methods');
});
