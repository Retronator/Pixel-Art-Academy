'use strict';

Package.describe({
	summary: "Meteor package to link/meld user accounts registered " +
	         "with the same (verified) email address.",
  version: "1.3.1",
  name: "retronator:accounts-meld",
  git: "https://github.com/splendido/meteor-accounts-meld.git",
});

Package.onUse(function(api) {
	api.use([
		'accounts-base',
		'check',
		'underscore',
		'retronator:accounts-emails-field',
	], ['server']);

	api.addFiles([
		'lib/_globals.js',
		'lib/accounts-meld-server.js',
		'lib/accounts-meld-hooks.js',
	], ['server']);

	api.imply([
		'accounts-base',
	], ['server']);

	api.export([
		'AccountsMeld',
		'MeldActions',
	], ['server']);
});
