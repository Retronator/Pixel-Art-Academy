Package.describe({
  name: 'retronator:sanfrancisco-c3',
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
  api.use('retronator:sanfrancisco');
  api.use('retronator:landsofillusions');
  api.use('retronator:landsofillusions-assets');

  api.export('SanFrancisco');

  api.addFile('c3');

  // Actors

  api.addFile('actors/actors');
  api.addFile('actors/receptionist');
  api.addFile('actors/drshelley');

  // Items

  api.addFile('items/items');
  api.addComponent('items/terminal/terminal');

  // Locations

  api.addThing('behavior/behavior');
  api.addComponent('behavior/terminal/terminal');
  api.addComponent('behavior/terminal/screens/mainmenu/mainmenu');
  api.addComponent('behavior/terminal/screens/character/character');
  api.addComponent('behavior/terminal/screens/personality/personality');
  api.addComponent('behavior/terminal/screens/personality/factor');
  api.addComponent('behavior/terminal/screens/personality/traits');
  api.addComponent('behavior/terminal/screens/activities/activities');
  api.addComponent('behavior/terminal/screens/environment/environment');
  api.addComponent('behavior/terminal/screens/people/people');
  api.addComponent('behavior/terminal/screens/perks/perks');

  api.addFile('behavior/terminal/components/components');
  api.addComponent('behavior/terminal/components/personalitypartpreview/personalitypartpreview');
  api.addComponent('behavior/terminal/components/activitypartspreview/activitypartspreview');
  api.addComponent('behavior/terminal/components/peoplepropertypreview/peoplepropertypreview');

  api.addThing('design..');
  api.addFile('design/templatepart');
  api.addComponent('design/terminal..');
  api.addComponent('design/terminal/screens/mainmenu..');
  api.addComponent('design/terminal/screens/character..');
  api.addComponent('design/terminal/screens/avatarpart..');

  api.addFile('design/terminal/components/components');
  api.addComponent('design/terminal/components/avatarpartpreview/avatarpartpreview');
  api.addComponent('design/terminal/components/customcolorpreview/customcolorpreview');

  api.addFile('design/terminal/properties..');
  api.addFile('design/terminal/properties/input');
  api.addFile('design/terminal/properties/property');
  api.addComponent('design/terminal/properties/oneof..');
  api.addComponent('design/terminal/properties/array..');
  api.addComponent('design/terminal/properties/color..');
  api.addComponent('design/terminal/properties/relativecolorshade..');
  api.addComponent('design/terminal/properties/haircolor..');
  api.addComponent('design/terminal/properties/sprite..');
  api.addComponent('design/terminal/properties/sprite/opendialog');
  api.addComponent('design/terminal/properties/string..');
  api.addComponent('design/terminal/properties/number..');
  api.addComponent('design/terminal/properties/integer..');
  api.addComponent('design/terminal/properties/boolean..');
  api.addComponent('design/terminal/properties/renderingcondition..');
  api.addComponent('design/terminal/properties/hideregions..');

  api.addThing('service..');
  api.addComponent('service/terminal..');
  api.addComponent('service/terminal/screens/mainmenu..');
  api.addComponent('service/terminal/screens/character..');
  api.addComponent('service/terminal/screens/modelselection..');

  api.addFile('hallway/hallway');
  api.addThing('lobby/lobby');

  api.addThing('stasis/stasis');
  api.addFile('stasis/emptyvat');
  api.addFile('stasis/vat');
  api.addFile('stasis/controlpanel');

  api.addThing('remotecontrol/remotecontrol');

});
