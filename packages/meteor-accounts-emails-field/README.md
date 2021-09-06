[![Build Status](https://travis-ci.org/splendido/meteor-accounts-emails-field.svg?branch=master)](https://travis-ci.org/splendido/meteor-accounts-emails-field)
accounts-emails-field
=====================

This is a Meteor package which maintains the `registered_emails` array field inside the [user object](http://docs.meteor.com/#meteor_users) up to date with any account service email used by the user to login into the application.

It exploits the [`onLogin`](http://docs.meteor.com/#/full/accounts_onlogin) hook from the Accounts object to check the user object after every successful login and possibly updates the content of its `registered_emails` field.

In particular:

* email addresses used with 3rd-party services are added to the `registered_emails` field
* email added with `accounts-password` service which are still not validated but appear inside some 3rd-party service as validated are promotes to validated also inside the `registered_emails` field.
* emails which do not appear anymore inside some 3rd-party service are deleted from the `registered_emails` field. In case the `accounts-password` service is used, the first email appearing inside the array, which is the one supposed to belong to the `accounts-password` service is anyway preserved inside `registered_emails`!

### Advantages:

Having an up-to-date `registered_emails` field should permit to find a registered user by any of its email addresses with a simple function like this:

```Javascript
var findUserByEmail = function(emailAddress){
    return Meteor.users.findOne({"registered_emails.address": emailAddress});
};
```

This should, among other things, permit to check whether a newly registered user has already another account for the application. This could happen when different account services are used at the same time (e.g. `accounts-password`, `accounts-google`, `accounts-github`, etc.) and the user don't remember with which service logged in originally. A simple check on the email address could reveal this uncomfortable scenario and permit the application to warn the user or even propose her to merge the two accounts...


### Installation

```Shell
meteor add splendido:accounts-emails-field
```

### Usage

Nothing to do... just install it and you're ready to go!

The `registered_emails` field that is automatically added to `Meteor.users` has the same format than the built-in [`emails`](http://docs.meteor.com/#/full/meteor_users) field:
```javascript
registered_emails: [
    { address: "cool@example.com", verified: true },
    { address: "another@different.com", verified: false }
  ],
```
If you use [aldeed:collection2](https://github.com/aldeed/meteor-collection2#attach-a-schema-to-meteorusers) on `Meteor.users`, you need to add the following field to your schema or you will get a collection2 exception each time a user logs in:
```javascript
registered_emails: { type: [Object], blackbox: true, optional: true }
```

### Advanced API

The `accounts-emails-field` exports an `AccountsEmailsField` object which in
turn makes available the following functions on the server only:

* `AccountsEmailsField.getEmailsFromService(serviceName, serviceObj)`:
    internally used to extract email informations from OAuth service objects to
    be found into the user object within the `services` field.

* `AccountsEmailsField.updateAllUsersEmails()`:
    handy function to update the `registered_emails` field for all known users
    at once. Possibly useful for initial database update in case the packge is
    added to an already existing application.

* `AccountsEmailsField.updateEmails({user: user})`:
    internally used to create/update the `registered_emails` field of a particular
    user object. Its signature is designed to match the one required for callbacks
    to be used with [Accounts.onLogin](https://docs.meteor.com/#/full/accounts_onlogin)
    (because it's actually used this way...).

If you need to track changes in the `registered_emails` field, declare your own [`onLogin`](http://docs.meteor.com/#/full/accounts_onlogin) hook. It will be called after the one set by `accounts-emails-field` and will allow you to update whatever data depending on `registered_emails`:

```javascript
Accounts.onLogin(function (info) {
	// If login was not successful, quit
	if (! info.user)
		return;

	// Get the user, including the registered_emails field added by the "splendido:accounts-emails-field"
	// package. We cannot rely on info.user here, because modifications to the info object are not 
	// propagated through onLogin callbacks (so info.user.registered_emails might be inexistent or out 
	// of date)
	var user = Meteor.users.findOne(info.user._id, { fields: { registered_emails: 1, ... } });

    // Use user.registered_emails here:
	...
});
```

### WIP

**This project is still Work In Progress**: any comments, suggestions, testing efforts, and PRs are very very welcome. Please use the [repo](https://github.com/splendido/meteor-accounts-emails-field) page for issues, discussions, etc.

In particular it would be very useful to test the package with as many accounts services as possible to confirm it is correctly functioning.
_**The major question mark is about the name used by each service to provide the email address**_ (so far `email` and `emailAddressed` were observed) and _**the presence of a field telling whether the same address was verified or not**_ (so far only for accounts-google a field called `verified_email` was found).

#### Already Tested Services

|  service  | let non-verified in |  email field  | email verified field |
| :-------- | :-----------------: | :-----------: | :------------------: |
| twitter   |          X          |               |                      |
| facebook  |                     |       X       |                      |
| google    |          X          |       X       |           X          |
| github    |          X          | (may be null) |                      |
| linkedin  |                     |       X       |                      |

See also [these lines](https://github.com/splendido/meteor-accounts-emails-field/blob/master/lib/accounts-emails-field.js#L13-69)
for more details.

#### Instructions for testers

Please try the following:

```Shell
meteor create test-accounts-emails-field && cd test-accounts-emails-field
meteor add twbs:bootstrap
meteor add ian:accounts-ui-bootstrap-3
meteor add service-configuration
meteor add accounts-YOUR_PREFERRED_SERVICE
meteor add splendido:accounts-emails-field
mkdir server
touch server/accounts.js
```

Then add the configuration required for your test app registered for the chosen service and finally run the application with:

```Shell
meteor
```

Head your browser to `localhost:3000` and try to login with your service. After this open the mongo shell with

```Shell
meteor mongo
```

from the same app folder but from a different terminal (while the testing app is still running) and type

```Shell
db.users.find().pretty()
```

Please try to confirm that the email you used to register to the service was added to the `registered_emails` field and try to see if it is marked as verified or not.
In case something is unexpected, please try to see under `user.services.YOUR_PREFERRED_SERVICE` which is the name for the email field (if any!) and whether there is another field stating the verified status of the email address (if any...).

In any case, please comment/add an issue having the same name of the service with the test outcome.

Big Tnx in advance to anyone willing to test `accounts-emails-field`!!!
