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

  api.export('Retropolis');

  api.addFiles('spaceport.coffee');

  // Locations

  api.addFiles('airportterminal/airportterminal.coffee');

  api.addFiles('airportterminal/concourse/terrace/terrace.coffee');
  api.addFiles('airportterminal/concourse/terrace/terrace.html');
  api.addFiles('airportterminal/concourse/terrace/terrace.styl');
  api.addFiles('airportterminal/concourse/terrace/retropolis.coffee');

  api.addFiles('airportterminal/concourse/concourse/concourse.coffee');

  api.addFiles('airportterminal/concourse/gates/gates.coffee');

  api.addFiles('airportterminal/arrivals/arrivals/arrivals.coffee');

  api.addFiles('airportterminal/arrivals/baggageclaim/baggageclaim.coffee');

  api.addFiles('airportterminal/arrivals/customs/customs.coffee');

  api.addFiles('airportterminal/arrivals/immigration/immigration.coffee');
  api.addFiles('airportterminal/arrivals/immigration/counter.coffee');
  api.addFiles('airportterminal/arrivals/immigration/officer.coffee');
  api.addAssets('airportterminal/arrivals/immigration/officer.script', ['client', 'server']);

  api.addFiles('airportterminal/departures/departures/departures.coffee');
  api.addFiles('airportterminal/departures/checkin/checkin.coffee');
  api.addFiles('airportterminal/departures/security/security.coffee');
  api.addFiles('airportterminal/departures/security/scanner.coffee');

  api.addFiles('tower/2ndlevel/atrium/atrium.coffee');
});
