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

  // Interface

  api.addFiles('interface/interface.coffee');

  api.addFiles('interface/components/components.coffee');
  api.addFiles('interface/components/narrative.coffee');
  api.addFiles('interface/components/commandinput.coffee');
  api.addFiles('interface/components/dialogueselection.coffee');
  api.addFiles('interface/components/audiomanager.coffee');

  api.addFiles('interface/text/text.coffee');
  api.addFiles('interface/text/text.html');
  api.addFiles('interface/text/text.styl');
  api.addFiles('interface/text/text-initialization.coffee');
  api.addFiles('interface/text/text-narrative.coffee');
  api.addFiles('interface/text/text-handlers.coffee');
  api.addFiles('interface/text/text-nodehandling.coffee');
  api.addFiles('interface/text/text-resizing.coffee');
  api.addFiles('interface/text/text-scrolling.coffee');

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
