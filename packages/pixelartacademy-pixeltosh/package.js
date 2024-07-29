Package.describe({
  name: 'retronator:pixelartacademy-pixeltosh',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:fatamorgana');
  api.use('retronator:pixelartacademy');

  api.export('PixelArtAcademy');

  api.addFile('pixeltosh');

  api.addFile('adventure..');

  api.addFile('program..');
  api.addComponent('program/view..');

  // HACK: We store programs in program since programs gets ignored by Meteor for legacy reasons.
  api.addFile('program/programs');

  api.addFile('program/finder..');
  api.addComponent('program/finder/files..');
  api.addComponent('program/finder/desktop..');
  api.addComponent('program/finder/folder..');

  api.addComponent('computer..');
  api.addComponent('os..');

  api.addFile('os/filesystem..');
  api.addFile('os/filesystem/file');
  api.addFile('os/filesystem/filetypes..');
  api.addFile('os/filesystem/filetypes/disk');
  api.addFile('os/filesystem/filetypes/folder');

  api.addFile('os/interface..');
  api.addComponent('os/interface/cursor..');
  api.addComponent('os/interface/titlebar..');
  api.addComponent('os/interface/window..');

  api.addFile('os/interface/actions..');
  api.addFile('os/interface/actions/action');
  api.addFile('os/interface/actions/open');
  api.addFile('os/interface/actions/close');
  api.addFile('os/interface/actions/closeall');
  api.addFile('os/interface/actions/quit');

  api.addFile('pages..');
  api.addComponent('pages/pixeltosh..');

  api.addComponent('instructions..');
  api.addFile('instructions/instruction');
});