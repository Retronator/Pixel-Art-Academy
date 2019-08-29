Package.describe({
  name: 'retronator:landsofillusions',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: 'Game engine for Pixel Art Academy, Retropolis and beyond.',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/Retronator/Landsofillusions.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'delaunator': '3.0.2',
  'barycentric': '1.0.1',
  'canvas': '2.3.1',
  'pngjs': '2.3.0',
  's3-streaming-upload': '0.2.3',
  'fast-png': '4.0.1'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:retronator-accounts');

  api.use('chfritz:easycron');
  api.use('jparker:crypto-aes');
  api.use('froatsnook:request');

  api.use('promise');
  api.use('webapp');

  api.imply('retronator:artificialengines');
  api.imply('retronator:retronator-accounts');

  api.export('LandsOfIllusions');

  api.addFile('landsofillusions');

  // Authorize

  api.addFile('authorize/authorize');
  api.addFile('authorize/user');
  api.addFile('authorize/character');

  // Settings

  api.addFile('settings..');
  api.addFile('settings/field');
  api.addFile('settings/consentfield');

  // Initialize client after settings have been defined.
  api.addClientFile('initialize-client');

  // Game state

  api.addFile('state/gamestate');
  api.addServerFile('state/gamestate-events-server');
  api.addFile('state/localgamestate');
  api.addFile('state/methods');
  api.addServerFile('state/subscriptions');
  api.addFile('state/stateobject');
  api.addFile('state/statefield');
  api.addFile('state/stateaddress');
  api.addFile('state/stateinstances');
  api.addFile('state/ephemeralstateobject');
  api.addFile('state/localsavegames');

  api.addServerFile('state/migrations/0000-immersionrevamp');
  api.addServerFile('state/migrations/0001-renamecollection');
  api.addServerFile('state/migrations/0002-gametime');
  api.addServerFile('state/migrations/0003-addinggamestatefields');
  api.addServerFile('state/migrations/0004-admissionapplication');
  api.addServerFile('state/migrations/0005-tutorialspritesremove');

  // Engine

  api.addFile('engine..');
  api.addFile('engine/renderingregion');
  api.addFile('engine/renderingsides');

  api.addClientFile('engine/textures..');
  api.addClientFile('engine/textures/palette');
  api.addClientFile('engine/textures/sprite');
  api.addClientFile('engine/textures/mip');

  api.addClientFile('engine/materials..');
  api.addClientFile('engine/materials/material');
  api.addClientFile('engine/materials/spritematerial');
  api.addClientFile('engine/materials/rampmaterial');
  api.addClientFile('engine/materials/depthmaterial');
  api.addClientFile('engine/materials/shadowcolormaterial');
  api.addClientFile('engine/materials/preprocessingmaterial');

  api.addClientFile('engine/materials/shaderchunks..');
  api.addClientFile('engine/materials/shaderchunks/lighting');
  api.addClientFile('engine/materials/shaderchunks/palette');
  api.addClientFile('engine/materials/shaderchunks/texture');
  api.addClientFile('engine/materials/shaderchunks/dither');
  api.addClientFile('engine/materials/shaderchunks/preprocessing');

  api.addFile('engine/debug..');
  api.addFile('engine/debug/dummysceneitem');

  // Avatar

  api.addFile('avatar/avatar');
  api.addFile('avatar/humanavatar..');
  api.addFile('avatar/humanavatar/renderobject');
  api.addFile('avatar/humanavatar/renderobject-bonecorrections');
  api.addFile('avatar/humanavatar/physicsobject');
  api.addFile('avatar/humanavatar/texturerenderer');
  api.addFile('avatar/humanavatar/regions');

  // Character

  api.addFile('character..');
  api.addServerFile('character/character-server-databasecontent');
  api.addFile('character/character-helpers');
  api.addFile('character/methods');
  api.addServerFile('character/methods-server-renderavatartextures');
  api.addServerFile('character/subscriptions');
  api.addServerFile('character/migrations/0000-renamecollection');
  api.addServerFile('character/migrations/0001-userpublicname');
  api.addServerFile('character/migrations/0002-ownername');
  api.addServerFile('character/migrations/0003-migrateavatarfields');
  api.addServerFile('character/migrations/0004-displayname');
  api.addServerFile('character/migrations/0005-usercharactersupdate');
  api.addServerFile('character/migrations/0006-linkpremadecharacters');
  api.addServerFile('character/migrations/0007-moveneckfield');
  api.addServerFile('character/migrations/0008-mergehairfields');
  api.addServerFile('character/migrations/0009-linkshapetemplates');
  api.addClientFile('character/spacebars');
  api.addFile('character/nonplayercharacter');
  api.addFile('character/instance');

  // Part system

  api.addFile('character/part/part');
  api.addServerFile('character/part/part-server-databasecontent');
  api.addFile('character/part/template');
  api.addServerFile('character/part/template-server-databasecontent');
  api.addServerFile('character/part/methods-server');
  api.addServerFile('character/part/subscriptions');
  
  api.addServerFile('character/part/migrations/0000-embeddedtranslations');
  api.addServerFile('character/part/migrations/0001-spriteids');
  api.addServerFile('character/part/migrations/0002-articlepartstoarticlepartshapes');
  api.addServerFile('character/part/migrations/0003-articlewitharticlepartshapes');

  api.addFile('character/part/property');
  api.addServerFile('character/part/property-server-databasecontent');

  api.addFile('character/part/properties/oneof');
  api.addFile('character/part/properties/array');
  api.addFile('character/part/properties/integer');
  api.addFile('character/part/properties/string');
  api.addFile('character/part/properties/boolean');
  api.addFile('character/part/properties/number');

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
  api.addFile('character/avatar/properties/haircolor');
  api.addFile('character/avatar/properties/outfitcolor');
  api.addFile('character/avatar/properties/sprite');
  api.addFile('character/avatar/properties/renderingcondition');
  api.addFile('character/avatar/properties/hideregions');

  api.addFile('character/avatar/renderers/renderers');
  api.addFile('character/avatar/renderers/renderer');
  api.addServerFile('character/avatar/renderers/renderer-server-databasecontent');
  api.addFile('character/avatar/renderers/shape');
  api.addFile('character/avatar/renderers/default');
  api.addFile('character/avatar/renderers/humanavatar');
  api.addFile('character/avatar/renderers/humanavatar-regionsorder');
  api.addFile('character/avatar/renderers/mappedshape');
  api.addFile('character/avatar/renderers/mappedshape-mapsprite');
  api.addFile('character/avatar/renderers/bodypart');
  api.addFile('character/avatar/renderers/body');
  api.addFile('character/avatar/renderers/head');
  api.addFile('character/avatar/renderers/hair');
  api.addFile('character/avatar/renderers/chest');
  api.addFile('character/avatar/renderers/outfitarticlepart');

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
  api.addFile('character/behavior/properties/factorsarray');

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

  // Group

  api.addFile('character/group..');
  api.addFile('character/group/methods');
  api.addServerFile('character/group/subscriptions');

  // Membership

  api.addFile('character/membership..');
  api.addServerFile('character/membership/server');
  api.addServerFile('character/membership/subscriptions');

  // Pre-made characters

  api.addFile('character/premadecharacter/premadecharacter');
  api.addServerFile('character/premadecharacter/premadecharacter-server-databasecontent');
  api.addFile('character/premadecharacter/methods');
  api.addServerFile('character/premadecharacter/subscriptions');

  api.addServerFile('character/premadecharacter/migrations/0000-renamecollection');

  // User

  api.addFile('user/user');
  api.addServerFile('user/subscriptions');

  // Parser

  api.addFile('parser..');
  api.addFile('parser/parser-likelyactions');
  api.addFile('parser/command');
  api.addFile('parser/commandresponse');
  api.addFile('parser/enterresponse');
  api.addFile('parser/exitresponse');

  api.addFile('parser/vocabulary/vocabulary');
  api.addFile('parser/vocabulary/vocabularykeys');
  api.addServerFile('parser/vocabulary/english-server');

  // Director

  api.addFile('director..');
  api.addFile('director/scriptqueue');

  // Adventure

  api.addComponent('adventure..');
  api.addFile('adventure/adventure-routing');
  api.addFile('adventure/adventure-state');
  api.addFile('adventure/adventure-memories');
  api.addFile('adventure/adventure-location');
  api.addFile('adventure/adventure-context');
  api.addFile('adventure/adventure-timeline');
  api.addFile('adventure/adventure-item');
  api.addFile('adventure/adventure-inventory');
  api.addFile('adventure/adventure-episodes');
  api.addFile('adventure/adventure-things');
  api.addFile('adventure/adventure-listeners');
  api.addFile('adventure/adventure-time');
  api.addFile('adventure/adventure-dialogs');
  api.addFile('adventure/adventure-assets');
  api.addFile('adventure/adventure-groups');

  // Initalization gets included last because it does component registering as the last child in the chain.
  api.addFile('adventure/adventure-initialization');

  // Situations

  api.addFile('adventure/situation..');
  api.addFile('adventure/situation/circumstance');

  // Listener

  api.addFile('adventure/listener..');
  
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
  api.addFiles('adventure/script/nodes/dialogueline.coffee');
  api.addFiles('adventure/script/nodes/narrativeline.coffee');
  api.addFiles('adventure/script/nodes/interfaceline.coffee');
  api.addFiles('adventure/script/nodes/commandline.coffee');
  api.addFiles('adventure/script/nodes/code.coffee');
  api.addFiles('adventure/script/nodes/conditional.coffee');
  api.addFiles('adventure/script/nodes/jump.coffee');
  api.addFiles('adventure/script/nodes/choice.coffee');
  api.addFiles('adventure/script/nodes/choiceplaceholder.coffee');
  api.addFiles('adventure/script/nodes/timeout.coffee');
  api.addFiles('adventure/script/nodes/pause.coffee');

  api.addFiles('adventure/script/parser/parser.coffee');

  // Character things (inherits from Thing and uses Script) and derivatives

  api.addFile('character/person');
  api.addFile('character/agent');
  api.addFile('character/actor');

  // Storylines

  api.addFile('adventure/global..');
  api.addFile('adventure/episode..');
  api.addFile('adventure/section..');
  api.addComponent('adventure/chapter..');
  api.addFile('adventure/scene..');
  api.addFile('adventure/scene/personconversation');
  api.addFile('adventure/scene/conversationbranch');

  // Locations and inventory

  api.addFile('adventure/region..');
  api.addFile('adventure/location..');
  api.addFile('adventure/location/inventory');

  // Groups

  api.addFile('adventure/group..');

  // Events
  
  api.addFile('adventure/event..');
  api.addFile('adventure/event/stopevent');

  // Context

  api.addFile('adventure/context..');

  // Agents (requires adventure global)

  api.addFile('character/agents');

  // Memories (requires adventure context and script nodes)

  api.addFile('memory..');
  api.addFile('memory/methods');
  api.addServerFile('memory/methods-server');
  api.addServerFile('memory/subscriptions');
  api.addServerFile('memory/migrations/0000-renamecollection');
  api.addServerFile('memory/migrations/0001-linesreversereferencefieldsupdate');
  api.addServerFile('memory/migrations/0002-renamecollection');
  api.addServerFile('memory/migrations/0003-changetomemories');
  api.addServerFile('memory/migrations/0004-actionsreversereferencefieldadded');

  api.addFile('memory/context');
  api.addFile('memory/contexts..');
  api.addFile('memory/contexts/conversation..');
  api.addComponent('memory/contexts/conversation/memorypreview..');

  api.addFile('memory/flashback');

  api.addFile('memory/action..');
  api.addFile('memory/action/methods');
  api.addServerFile('memory/action/subscriptions');
  api.addServerFile('memory/action/migrations/0000-renamecollection');
  api.addServerFile('memory/action/migrations/0001-characterreferencefieldsupdate');
  api.addServerFile('memory/action/migrations/0002-removecharacternamefield');
  api.addServerFile('memory/action/migrations/0003-renamecollection');
  api.addServerFile('memory/action/migrations/0004-changetomemories');

  api.addFile('memory/actions..');
  api.addFile('memory/actions/move');
  api.addFile('memory/actions/leave');
  api.addFile('memory/actions/say');

  api.addFile('memory/progress..');
  api.addFile('memory/progress/methods');
  api.addServerFile('memory/progress/subscriptions');

  // Parser Listeners

  api.addFile('parser/listeners/debug');
  api.addFile('parser/listeners/navigation');
  api.addFile('parser/listeners/description');
  api.addFile('parser/listeners/looklocation');
  api.addFile('parser/listeners/conversation');
  api.addFile('parser/listeners/advertisedcontext');
  api.addFile('parser/listeners/help');

  // Interface

  api.addFiles('interface/interface.coffee');

  api.addFiles('interface/components/components.coffee');
  api.addFiles('interface/components/narrative.coffee');
  api.addFiles('interface/components/commandinput.coffee');
  api.addFiles('interface/components/dialogueselection.coffee');

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

  api.addFile('pages..');

  api.addComponent('pages/loading..');

  api.addUnstyledComponent('pages/admin..');

  api.addUnstyledComponent('pages/admin/characters..');
  api.addServerFile('pages/admin/characters/avatartexture');

  api.addComponent('pages/admin/characters/avatareditor..');
  api.addComponent('pages/admin/characters/characters..');
  api.addComponent('pages/admin/characters/templates..');

  api.addUnstyledComponent('pages/admin/characters/premadecharacters/premadecharacters');
  api.addServerFile('pages/admin/characters/premadecharacters/methods-server');

  api.addComponent('pages/admin/characters/approveddesigns..');
  api.addServerFile('pages/admin/characters/approveddesigns/subscriptions');

  api.addComponent('pages/admin/characters/outfitstest..');
  api.addData('pages/admin/characters/outfitstest/bodies/ectomorph');
  api.addData('pages/admin/characters/outfitstest/bodies/mesomorph');
  api.addData('pages/admin/characters/outfitstest/bodies/endomorph');
  api.addData('pages/admin/characters/outfitstest/bodies/female-ectomorph2');
  api.addData('pages/admin/characters/outfitstest/bodies/female-ectomorph3');
  api.addData('pages/admin/characters/outfitstest/bodies/female-mesomorph1');
  api.addData('pages/admin/characters/outfitstest/bodies/female-mesomorph2');
  api.addData('pages/admin/characters/outfitstest/bodies/female-mesomorph3');
  api.addData('pages/admin/characters/outfitstest/bodies/female-endomorph1');
  api.addData('pages/admin/characters/outfitstest/bodies/female-endomorph2');
  api.addData('pages/admin/characters/outfitstest/bodies/female-endomorph4');
  api.addData('pages/admin/characters/outfitstest/bodies/female-endomorph5');
  api.addData('pages/admin/characters/outfitstest/bodies/male-ectomorph1');
  api.addData('pages/admin/characters/outfitstest/bodies/male-mesomorph3');
  api.addData('pages/admin/characters/outfitstest/bodies/male-endomorph2');
  api.addData('pages/admin/characters/outfitstest/bodies/male-endomorph3');
  api.addData('pages/admin/characters/outfitstest/bodies/male-endomorph4');

  // Components

  api.addFile('components..');

  api.addFile('components/mixins..');
  api.addFile('components/mixins/activatable..');

  api.addComponent('components/overlay..');
  api.addComponent('components/backbutton..');
  api.addComponent('components/signin..');
  api.addComponent('components/storylinetitle..');
  api.addComponent('components/hand..');

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
  
  api.addComponent('components/translationinput..');
  api.addUnstyledComponent('components/sprite..');
  api.addUnstyledComponent('components/computer..');

  api.addUnstyledComponent('components/embeddedwebpage..');

  // Typography

  api.addCss('typography..');
  api.addStyleImport('typography..');

  // Styles

  api.addStyleImport('style..');
  api.addStyleImport('style/atari2600');
  api.addStyleImport('style/cursors');
  api.addStyle('style/cursors');
  api.addStyle('style/defaults');

  // Helpers

  api.addFile('helpers/spacebars');
  api.addFile('helpers/lodash');
  
  // Emails

  api.addFile('emails..');
  api.addFile('emails/email');
  api.addServerFile('emails/email-server');
  api.addFile('emails/inbox');

  // Time

  api.addFile('time..');
  api.addFile('time/gamedate');

  // Simulation

  api.addFile('simulation..');
  api.addServerFile('simulation/server');

  // Engine world

  api.addComponent('engine/world..');
  api.addFile('engine/world/renderermanager');
  api.addFile('engine/world/scenemanager');
  api.addFile('engine/world/cameramanager');
  api.addFile('engine/world/audiomanager');
  api.addFile('engine/world/physicsmanager');
  api.addFile('engine/world/mouse');
  api.addFile('engine/world/navigator..');
  api.addFile('engine/world/navigator/spaceoccupation..');
  api.addFile('engine/world/navigator/spaceoccupation/placeholder');
});
