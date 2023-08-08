Package.describe({
  name: 'retronator:landsofillusions-ui',
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
  api.use('retronator:landsofillusions');
  api.imply('retronator:landsofillusions');

  api.use('retronator:landsofillusions-assets');

  api.export('LandsOfIllusions');

  api.addFile('component');

  // Interface

  api.addFile('interface/interface');

  api.addFile('interface/components/components');
  api.addFile('interface/components/narrative');
  api.addFile('interface/components/commandinput');
  api.addFile('interface/components/dialogueselection');
  api.addFile('interface/components/audiomanager');

  api.addComponent('interface/text/text');
  api.addFile('interface/text/text-initialization');
  api.addFile('interface/text/text-narrative');
  api.addFile('interface/text/text-handlers');
  api.addFile('interface/text/text-nodehandling');
  api.addFile('interface/text/text-resizing');
  api.addFile('interface/text/text-scrolling');

  // Components

  api.addFile('components..');

  api.addFile('components/mixins..');
  api.addFile('components/mixins/activatable..');

  api.addComponent('components/overlay..');
  api.addComponent('components/backbutton..');
  api.addComponent('components/signin..');
  api.addStyle('components/savesystem..');
  api.addComponent('components/savegame..');
  api.addComponent('components/loadgame..');
  api.addComponent('components/storylinetitle..');
  api.addComponent('components/hand..');
  api.addComponent('components/translationinput..');

  api.addComponent('components/menu..');
  api.addComponent('components/menu/items..');

  api.addComponent('components/account..');
  api.addFile('components/account/account-page');
  api.addStyle('components/account/account-pagecontent');

  api.addComponent('components/account/contents..');
  api.addComponent('components/account/general..');
  api.addComponent('components/account/services..');
  api.addComponent('components/account/characters..');
  api.addComponent('components/account/inventory..');
  api.addComponent('components/account/transactions..');
  api.addComponent('components/account/paymentmethods..');

  api.addStyle('components/dialogs/accounts');
  api.addComponent('components/dialogs/dialog');

  api.addUnstyledComponent('components/sprite..');
  api.addUnstyledComponent('components/computer..');

  api.addUnstyledComponent('components/embeddedwebpage..');
  api.addFile('components/embeddedwebpage/display');
  api.addFile('components/embeddedwebpage/router');
});
