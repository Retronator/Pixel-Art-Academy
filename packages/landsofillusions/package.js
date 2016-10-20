Package.describe({
  name: 'retronator:landsofillusions',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: 'Game engine for Pixel Art Academy, Retropolis and beyond.',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/Retronator/Lands-of-Illusions.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:accounts');

  api.imply('retronator:artificialengines');
  api.imply('retronator:accounts');

  api.export('LandsOfIllusions');

  api.addFiles('landsofillusions.coffee');

  // Authorize

  api.addFiles('authorize/authorize.coffee');
  api.addFiles('authorize/user.coffee');
  api.addFiles('authorize/character.coffee');

  // Character

  api.addFiles('character/spacebars.coffee', 'client');
  api.addFiles('character/character.coffee');
  api.addFiles('character/methods.coffee');
  api.addFiles('character/subscriptions.coffee', 'server');

  // Avatar

  api.addFiles('avatar/avatar.coffee');

  // Assets

  api.addFiles('assets/assets.coffee');
  api.addFiles('assets/server.coffee');

  api.addFiles('assets/palette/palette.coffee');
  api.addFiles('assets/palette/atari2600.coffee');
  api.addFiles('assets/palette/subscriptions.coffee', 'server');

  api.addFiles('assets/sprite/sprite.coffee');

  api.addFiles('assets/mesh/mesh.coffee');

  // Adventure

  api.addFiles('adventure/adventure.html');
  api.addFiles('adventure/adventure.styl');
  api.addFiles('adventure/adventure.coffee');

  api.addFiles('adventure/item.coffee');
  api.addFiles('adventure/director.coffee');

  // Location

  api.addFiles('adventure/location/location.coffee');
  api.addFiles('adventure/location/location.html');
  api.addFiles('adventure/location/location.styl');

  // Actor

  api.addFiles('adventure/actor/actor.coffee');

  api.addFiles('adventure/actor/ability.coffee');
  api.addFiles('adventure/actor/abilities/abilities.coffee');

  api.addFiles('adventure/actor/abilities/action.coffee');
  api.addFiles('adventure/actor/abilities/talking.coffee');

  // Script

  api.addFiles('adventure/script/script.coffee');
  api.addFiles('adventure/script/node.coffee');
  api.addFiles('adventure/script/nodes/nodes.coffee');
  api.addFiles('adventure/script/nodes/dialogline.coffee');

  // Parser

  api.addFiles('adventure/parser/parser.coffee');
  api.addFiles('adventure/parser/command.coffee');

  api.addFiles('adventure/parser/parts/abilities.coffee');
  api.addFiles('adventure/parser/parts/navigation.coffee');
  
  api.addFiles('adventure/parser/vocabulary/vocabulary.coffee');
  api.addFiles('adventure/parser/vocabulary/vocabularykeys.coffee');
  api.addFiles('adventure/parser/vocabulary/english-server.coffee', 'server');

  // Interface

  api.addFiles('adventure/interface/interface.coffee');

  api.addFiles('adventure/interface/components/components.coffee');
  api.addFiles('adventure/interface/components/narrative.coffee');
  api.addFiles('adventure/interface/components/commandinput.coffee');

  api.addFiles('adventure/interface/text/text.coffee');
  api.addFiles('adventure/interface/text/text.html');
  api.addFiles('adventure/interface/text/text.styl');

  api.addFiles('adventure/interface/text/resizing.coffee');

  // Conversations

  api.addFiles('conversations/conversations.coffee');
  api.addFiles('conversations/conversation.coffee');
  api.addFiles('conversations/line.coffee');
  api.addFiles('conversations/methods.coffee');
  api.addFiles('conversations/subscriptions.coffee', 'server');

  // Pages

  api.addFiles('pages/pages.coffee');
  api.addFiles('pages/loading/loading.coffee');
  api.addFiles('pages/loading/loading.html');
  api.addFiles('pages/loading/loading.styl');

  // Typography

  api.addFiles('typography/typography.css', 'client');
  api.addFiles('typography/typography.import.styl', 'client', {isImport:true});

  // Styles

  api.addFiles('styles/styles.coffee');
  api.addFiles('styles/console.coffee');
  api.addFiles('styles/console.html');
  api.addFiles('styles/console.styl');
  api.addFiles('styles/console-accountsui.styl');
  api.addFiles('styles/helpers.import.styl', 'client', {isImport:true});
  api.addFiles('styles/atari2600.import.styl', 'client', {isImport:true});

});
