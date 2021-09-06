'use strict';


Package.describe({
	summary: "Adds to the user obj a `registered_emails` field " +
		"containing 3rd-party account service emails.",
	name: "retronator:accounts-emails-field",
	version: "1.2.0",
	git: "https://github.com/splendido/meteor-accounts-emails-field.git",
});

Package.onUse(function(api) {
	api.use([
		'accounts-base',
		'underscore'
	], ['server']);

	api.imply([
		'accounts-base',
	], ['server']);

	api.addFiles([
		'lib/_globals.js',
		'lib/accounts-emails-field.js',
		'lib/accounts-emails-field-on-login.js'
	], ['server']);

	api.export([
		'AccountsEmailsField'
	], ['server']);
});
