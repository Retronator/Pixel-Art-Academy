Package.describe({
  name: 'retronator:retropolis-spaceport',
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
  api.use('retronator:retropolis');
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-items');

  api.export('Retropolis');

  api.addFile('spaceport');

  // Items

  api.addFile('items/items');
  api.addFile('items/announcer');

  // Locations

  api.addFile('airportterminal/airportterminal');

  api.addComponent('airportterminal/concourse/terrace/terrace');
  api.addFile('airportterminal/concourse/terrace/retropolis');
  api.addThing('airportterminal/concourse/terrace/vendingmachine');

  api.addFile('airportterminal/concourse/concourse/concourse');

  api.addFile('airportterminal/concourse/gates/gates');

  api.addThing('airportterminal/arrivals/arrivals/arrivals');

  api.addThing('airportterminal/arrivals/baggageclaim/baggageclaim');
  api.addFile('airportterminal/arrivals/baggageclaim/baggagecarousel');

  api.addFile('airportterminal/arrivals/customs/customs');

  api.addThing('airportterminal/arrivals/immigration/immigration');
  api.addThing('airportterminal/arrivals/immigration/terminal');

  api.addFile('airportterminal/departures/departures/departures');
  api.addFile('airportterminal/departures/checkin/checkin');
  api.addFile('airportterminal/departures/security/security');
  api.addFile('airportterminal/departures/security/scanner');

  api.addFile('tower/tower');
  api.addFile('tower/2ndlevel/atrium/atrium');

  api.addFile('airshipterminal/airshipterminal');

  api.addFile('airshipterminal/terminal/terminal');
  api.addFile('airshipterminal/terminal/schedule');
  api.addFile('airshipterminal/terminal/routesmap');

  api.addFile('airshipterminal/dock/dock');

  api.addFile('airshipterminal/airship/airship');
  api.addFile('airshipterminal/airship/cabin/cabin');
});
