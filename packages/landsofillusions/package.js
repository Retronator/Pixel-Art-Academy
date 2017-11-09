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
  api.use('retronator:retronator-accounts');
  api.use('http');
  api.use('promise');
  api.use('modules');

  api.imply('retronator:artificialengines');
  api.imply('retronator:retronator-accounts');

  api.export('LandsOfIllusions');

  api.addFiles('landsofillusions.coffee');

  // Authorize

  api.addFiles('authorize/authorize.coffee');
  api.addFiles('authorize/user.coffee');
  api.addFiles('authorize/character.coffee');

  // Game state

  api.addFiles('state/gamestate.coffee');
  api.addFiles('state/localgamestate.coffee');
  api.addFiles('state/methods.coffee');
  api.addFiles('state/subscriptions.coffee', 'server');
  api.addFiles('state/stateobject.coffee');
  api.addFiles('state/statefield.coffee');
  api.addFiles('state/stateaddress.coffee');
  api.addFiles('state/stateinstances.coffee');
  api.addFiles('state/ephemeralstateobject.coffee');
  api.addFiles('state/localsavegames.coffee');

  api.addServerFile('state/migrations/0000-immersionrevamp');
  api.addServerFile('state/migrations/0001-renamecollection');

  // Avatar

  api.addFile('avatar/avatar');
  api.addFile('avatar/humanavatar');

  // Character

  api.addFile('character/character');
  api.addFile('character/instance');
  api.addFile('character/methods');
  api.addServerFile('character/subscriptions');
  api.addServerFile('character/migrations/0000-renamecollection');
  api.addServerFile('character/migrations/0001-userpublicname');
  api.addServerFile('character/migrations/0002-ownername');
  api.addServerFile('character/migrations/0003-migrateavatarfields');
  api.addServerFile('character/migrations/0004-displayname');
  api.addServerFile('character/migrations/0005-usercharactersupdate');
  api.addClientFile('character/spacebars');
  
  // Part system

  api.addFile('character/part/part');
  api.addFile('character/part/template');
  api.addFile('character/part/methods');
  api.addServerFile('character/part/subscriptions');
  
  api.addServerFile('character/part/migrations/0000-embeddedtranslations');
  api.addServerFile('character/part/migrations/0001-spriteids');

  api.addFile('character/part/property');
  api.addFile('character/part/properties/oneof');
  api.addFile('character/part/properties/array');
  api.addFile('character/part/properties/integer');
  api.addFile('character/part/properties/string');
  api.addFile('character/part/properties/boolean');
  
  // Avatar parts

  api.addFile('character/avatar/avatar');
  api.addFile('character/avatar/landmark');

  api.addFile('character/avatar/parts/parts');
  api.addFile('character/avatar/parts/shape');
  api.addFile('character/avatar/parts/skinshape');
  api.addFile('character/avatar/parts/partwithcustomcolors');

  api.addFile('character/avatar/properties/properties');
  api.addFile('character/avatar/properties/color');
  api.addFile('character/avatar/properties/relativecolorshade');
  api.addFile('character/avatar/properties/sprite');

  api.addFile('character/avatar/renderers/renderers');
  api.addFile('character/avatar/renderers/renderer');
  api.addFile('character/avatar/renderers/shape');
  api.addFile('character/avatar/renderers/default');
  api.addFile('character/avatar/renderers/humanavatar');
  api.addFile('character/avatar/renderers/mappedshape');
  api.addFile('character/avatar/renderers/bodypart');
  api.addFile('character/avatar/renderers/body');
  api.addFile('character/avatar/renderers/head');
  api.addFile('character/avatar/renderers/chest');
  api.addFile('character/avatar/renderers/breasts');

  api.addFile('character/avatar/landmarks/position');

  api.addFile('character/avatar/initialize/body');
  api.addFile('character/avatar/initialize/outfit');

  // Behavior parts

  api.addFile('character/behavior/behavior');
  
  api.addFile('character/behavior/parts/parts');
  api.addFile('character/behavior/parts/personality');
  api.addFile('character/behavior/parts/personality-factor');
  api.addFile('character/behavior/parts/trait');
  api.addFile('character/behavior/parts/activity');
  api.addFile('character/behavior/parts/environment');
  api.addFile('character/behavior/parts/perk');

  api.addFile('character/behavior/properties/activities');
  api.addFile('character/behavior/properties/people');
  api.addFile('character/behavior/properties/perks');
  api.addFile('character/behavior/properties/traits');

  api.addFile('character/behavior/initialize/behavior');
  api.addFile('character/behavior/initialize/personality');
  api.addFile('character/behavior/initialize/traits-data');
  api.addFile('character/behavior/initialize/traits');
  api.addFile('character/behavior/initialize/activities');

  // Perk definitions must come after properties/perks and initialize/behavior.
  api.addFile('character/behavior/parts/perks/deadendjob');
  api.addFile('character/behavior/parts/perks/creativemess');
  api.addFile('character/behavior/parts/perks/minimalist');
  api.addFile('character/behavior/parts/perks/nothingtoclean');
  api.addFile('character/behavior/parts/perks/nofreetime');
  api.addFile('character/behavior/parts/perks/renaissancesoul');
  api.addFile('character/behavior/parts/perks/focused');
  api.addFile('character/behavior/parts/perks/spontaneous');
  api.addFile('character/behavior/parts/perks/organized');
  api.addFile('character/behavior/parts/perks/introvert');
  api.addFile('character/behavior/parts/perks/socializer');
  api.addFile('character/behavior/parts/perks/competitor');
  api.addFile('character/behavior/parts/perks/teammate');

  // User

  api.addFile('user/user');
  api.addServerFile('user/subscriptions');

  // Conversations

  api.addFile('conversations/conversations');

  api.addFile('conversations/conversation/conversation');
  api.addFile('conversations/conversation/methods');
  api.addServerFile('conversations/conversation/subscriptions');
  api.addServerFile('conversations/conversation/migrations/0000-renamecollection');
  api.addServerFile('conversations/conversation/migrations/0001-linesreversereferencefieldsupdate');

  api.addFile('conversations/line/line');
  api.addFile('conversations/line/methods');
  api.addServerFile('conversations/line/subscriptions');
  api.addServerFile('conversations/line/migrations/0000-renamecollection');
  api.addServerFile('conversations/line/migrations/0001-characterreferencefieldsupdate');
  api.addServerFile('conversations/line/migrations/0002-removecharacternamefield');

  // Parser

  api.addFiles('parser/parser.coffee');
  api.addFiles('parser/parser-likelyactions.coffee');
  api.addFiles('parser/command.coffee');
  api.addFiles('parser/commandresponse.coffee');
  api.addFiles('parser/enterresponse.coffee');
  api.addFiles('parser/exitresponse.coffee');

  api.addFiles('parser/vocabulary/vocabulary.coffee');
  api.addFiles('parser/vocabulary/vocabularykeys.coffee');
  api.addFiles('parser/vocabulary/english-server.coffee', 'server');

  // Director

  api.addFiles('director/director.coffee');

  // Adventure

  api.addFiles('adventure/adventure.html');
  api.addFiles('adventure/adventure.styl');
  api.addFiles('adventure/adventure.coffee');
  api.addFiles('adventure/adventure-routing.coffee');
  api.addFiles('adventure/adventure-state.coffee');
  api.addFiles('adventure/adventure-location.coffee');
  api.addFiles('adventure/adventure-timeline.coffee');
  api.addFiles('adventure/adventure-item.coffee');
  api.addFiles('adventure/adventure-inventory.coffee');
  api.addFiles('adventure/adventure-episodes.coffee');
  api.addFiles('adventure/adventure-things.coffee');
  api.addFiles('adventure/adventure-listeners.coffee');
  api.addFiles('adventure/adventure-time.coffee');
  api.addFiles('adventure/adventure-dialogs.coffee');

  // Initalization gets included last because it does component registering as the last child in the chain.
  api.addFiles('adventure/adventure-initialization.coffee');

  // Situations

  api.addFiles('adventure/situation/situation.coffee');
  api.addFiles('adventure/situation/circumstance.coffee');

  // Listener

  api.addFiles('adventure/listener/listener.coffee');
  
  // Thing

  api.addUnstyledComponent('adventure/thing/thing');
  api.addFile('adventure/thing/avatar');

  // Item

  api.addFile('adventure/item/item');

  // Script

  api.addFiles('adventure/script/scriptfile.coffee');
  api.addFiles('adventure/script/script.coffee');

  api.addFiles('adventure/script/helpers/helpers.coffee');
  api.addFiles('adventure/script/helpers/iteminteraction.coffee');

  api.addFiles('adventure/script/node.coffee');
  api.addFiles('adventure/script/nodes/nodes.coffee');
  api.addFiles('adventure/script/nodes/script.coffee');
  api.addFiles('adventure/script/nodes/label.coffee');
  api.addFiles('adventure/script/nodes/callback.coffee');
  api.addFiles('adventure/script/nodes/dialogline.coffee');
  api.addFiles('adventure/script/nodes/narrativeline.coffee');
  api.addFiles('adventure/script/nodes/interfaceline.coffee');
  api.addFiles('adventure/script/nodes/commandline.coffee');
  api.addFiles('adventure/script/nodes/code.coffee');
  api.addFiles('adventure/script/nodes/conditional.coffee');
  api.addFiles('adventure/script/nodes/jump.coffee');
  api.addFiles('adventure/script/nodes/choice.coffee');
  api.addFiles('adventure/script/nodes/timeout.coffee');
  api.addFiles('adventure/script/nodes/pause.coffee');

  api.addFiles('adventure/script/parser/parser.coffee');

  // Storylines

  api.addFiles('adventure/global/global.coffee');
  api.addFiles('adventure/episode/episode.coffee');
  api.addFiles('adventure/section/section.coffee');
  api.addComponent('adventure/chapter/chapter');
  api.addFiles('adventure/scene/scene.coffee');

  // Locations and inventory

  api.addFiles('adventure/region/region.coffee');
  api.addFiles('adventure/location/location.coffee');
  api.addFiles('adventure/location/inventory.coffee');

  // Parser Listeners

  api.addFiles('parser/listeners/debug.coffee');
  api.addFiles('parser/listeners/navigation.coffee');
  api.addFiles('parser/listeners/description.coffee');
  api.addFiles('parser/listeners/looklocation.coffee');

  // Interface

  api.addFiles('interface/interface.coffee');

  api.addFiles('interface/components/components.coffee');
  api.addFiles('interface/components/narrative.coffee');
  api.addFiles('interface/components/commandinput.coffee');
  api.addFiles('interface/components/dialogselection.coffee');

  api.addFiles('interface/text/text.coffee');
  api.addFiles('interface/text/text.html');
  api.addFiles('interface/text/text.styl');
  api.addFiles('interface/text/text-initialization.coffee');
  api.addFiles('interface/text/text-narrative.coffee');
  api.addFiles('interface/text/text-handlers.coffee');
  api.addFiles('interface/text/text-nodehandling.coffee');
  api.addFiles('interface/text/text-resizing.coffee');
  api.addFiles('interface/text/text-scrolling.coffee');

  // Pages

  api.addFiles('pages/pages.coffee');
  api.addFiles('pages/loading/loading.coffee');
  api.addFiles('pages/loading/loading.html');
  api.addFiles('pages/loading/loading.styl');

  // Components

  api.addFiles('components/components.coffee');

  api.addFile('components/mixins/mixins');
  api.addFile('components/mixins/activatable/activatable');

  api.addComponent('components/overlay/overlay');
  api.addComponent('components/backbutton/backbutton');
  api.addComponent('components/signin/signin');
  api.addComponent('components/storylinetitle/storylinetitle');

  api.addComponent('components/menu/menu');
  api.addComponent('components/menu/items/items');

  api.addComponent('components/account/account');
  api.addFile('components/account/account-page');
  api.addStyle('components/account/account-pagecontent');

  api.addComponent('components/account/contents/contents');
  api.addComponent('components/account/general/general');
  api.addComponent('components/account/services/services');
  api.addComponent('components/account/characters/characters');
  api.addComponent('components/account/inventory/inventory');
  api.addComponent('components/account/transactions/transactions');
  api.addComponent('components/account/paymentmethods/paymentmethods');

  api.addStyle('components/dialogs/accounts');
  api.addComponent('components/dialogs/dialog');
  
  api.addComponent('components/translationinput/translationinput');
  api.addUnstyledComponent('components/sprite/sprite');
  api.addUnstyledComponent('components/computer/computer');

  // Typography

  api.addFiles('typography/typography.css', 'client');
  api.addFiles('typography/typography.import.styl', 'client', {isImport:true});

  // Styles

  api.addFiles('style/style.import.styl', 'client', {isImport:true});
  api.addFiles('style/atari2600.import.styl', 'client', {isImport:true});
  api.addFiles('style/cursors.import.styl', 'client', {isImport:true});
  api.addFiles('style/cursors.styl');
  api.addFiles('style/defaults.styl');

  // Helpers

  api.addFiles('helpers/spacebars.coffee');
  api.addFiles('helpers/lodash.coffee');

});
