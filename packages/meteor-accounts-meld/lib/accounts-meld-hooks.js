/* global
	checkForMelds: false,
	updateOrCreateUserFromExternalService: false
*/
'use strict';

// Register `updateOrCreateUserFromExternalService` function to
// be used in place of the original
// `Accounts.updateOrCreateUserFromExternalService`
Accounts.updateOrCreateUserFromExternalService =
	updateOrCreateUserFromExternalService;


// Register `updateEmails` and checkPasswordLogin` functions
// to be triggered with the `onLogin` hook
Accounts.onLogin(function(attempt) {

	// Reload user object which was possibly modified
	// by splendido:accounts-emails-field by a previous onLogin callback
	// note: the *attempt* object is cloned for each hook callback
	//       se there's no way to get the modified user object from the
	//       *attempt* one...
	var user = Meteor.users.findOne(attempt.user._id);

	// Checks for possible meld actions to be created
	checkForMelds(user);
});
