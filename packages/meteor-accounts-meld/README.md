[![Build Status](https://travis-ci.org/splendido/meteor-accounts-meld.svg?branch=master)](https://travis-ci.org/splendido/meteor-accounts-meld)

# accounts-meld

Meteor package to meld user accounts registered with the same email address, or simply associate many different 3rd-party login services with the same user account.

## Some Details
Originally conceived as a core part of the package [accounts-templates-core](https://atmospherejs.com/package/accounts-templates-core), was finally released as an independent package to let everyone interested exploit it their own way.

For a very basic working example [test-account-meld](https://github.com/splendido/test-accounts-meld) can be cloned and configured with the preferred login services specifying their configuration inside [this](https://github.com/splendido/test-accounts-meld/blob/master/server/accounts.js) file.

In a near future, its integration within the package [accounts-templates-core](https://atmospherejs.com/package/accounts-templates-core) will be available for testing at any of the live examples linked from http://accounts-templates.meteor.com

A very basic example, styled for twitter [bootstrap](http://getbootstrap.com/), showing how to write the templates to present the final user with the choice about whether to meld or not to meld two accounts registered with the same email address, is provided with the package [accounts-meld-client-bootstrap](https://atmospherejs.com/package/accounts-meld-client-bootstrap).
For more details about this topic, please have a look at the [Documentation](#Documentation) below.

Enjoy!


#### Table of Contents
* [Introduction](#Introduction)
* [Features](#Features)
* [Disclaimer](#Disclaimer)
* [Acknowledgements](#Acknowledgements)
* [Documentation](#Documentation)
   * [Logic](#Logic)
   * [Melding](#Melding)
   * [Package Configuration](#PackageConfiguration)
* [MeldActions](#MeldActions)
* [How to Ensure Everything Works as Expected](#EnsureEverythingWorks)
* [Behind The Scenes](#BehindTheScenes)



<a name="Introduction"/>
## Introduction

accounts-meld tried to address the following aspects:

1. No two accounts registered with the same email address can exist
2. Many different 3rd-party login services could be associated with the same user account
3. Different accounts created in different times referring to the same email address might/should be melded together.

There might be many reasons for an application to wish to address the above points. Examples could be:

* preventing a user to register herself using different services to exploit some initial trial offer more than once (1.)
* leverage the integration with many different social networks to provide a better user experience (2.)
* gather as many information as possible, about a particular user, from different services (2.)
*  let a user, which has forgotten which service used to register to the application, the ability to recover the old account and all the information associated with it (3.)

and possibly more than these...



<a name="Features"/>
## Features

* Server-side code only!
* Fewest possible login operations to save round trip information exchanges with the server.
* Optional callback to be used for document migration.
* Customizable users' object melding not to lose any information.
* Optional interaction with the user (by means of a few additional templates not included with the core package) to ask whether to perform a meld action or not.
* Will meld accounts from the following login services (more will be added, see the *Disclaimer* chapter below):

|  Service  | Will meld  |  Reason
| :-------- | :--------: | :-----------
| Twitter   |    No      | Twitter does not provide any email information.
| Facebook  | -- Yes --  | Facebook provides the user email + Facebook enrolment process ensures this email is verified.
| Google    | -- Yes --  | Google provides a "verified email" field.
| GitHub    |    No      | GitHub does not provide a way to know if the user email is verified.
| LinkedIn  | -- Yes --  | LinkedIn provides the user email + LinkedIn enrolment process ensures this email is verified

To add support for LinkedIn, use the package [pauli:accounts-linkedin](https://github.com/PauliBuccini/meteor-accounts-linkedin/) and add the `r_emailaddress` permission to your LinkedIn app (section *OAuth User Agreement* of the app settings).

<a name="Disclaimer"/>
## Disclaimer

*The present work is released, as is, under the MIT license and, in no cases, for no reasons, the author can be considered responsible for any information losses or any possible damages derived by its use.*

For security reasons all the rationale behind accounts-meld is based upon **verified** email addresses. This is to prevent any malicious user to register herself using another user's email address and instantly being asked/allowed to meld the new account with the *old* one originally belonging to the user under **identity theft attack**!

All the logic put in place to detect pairs of accounts possibly belonging to the same user is based on the `registered_emails` field provided by the use of [accounts-emails-field](https://atmospherejs.com/package/accounts-emails-field) package.

**I strongly suggest (and encourage) anyone possibly interested in using accounts-meld to personally check how the services that will be made available work. Especially, please verify whether it is possible to use them to login to another application before the registered email address was verified!**

It would be very kind of you if any verification attempt, either successful or not, could be published among the [issues](https://github.com/splendido/meteor-accounts-emails-field/issues) for the repository of accounts-email field. The three major points being:

* assess whether there is a field, among the service information provided soon after the login, stating the email verification state (e.g. google provides the field `verified_email` while linkedin and facebook provides none)
* confirm that the email address registered with the service is provided under the field `email` or the field `emailAddress` (linkedin)
* try to register a new user with a specific service and next try to use the same service to login into the application before confirming/verifying the email ownership.

After reporting, the logic behind the package accounts-emails-field could be aligned with the result of the above checks so to ensure correct behaviour with as many services as possible!

Here is a list of already tested services:

|  service  | let non-verified in |  email field  | email verified field |
| :-------- | :-----------------: | :-----------: | :------------------: |
| twitter   |          X          |               |                      |
| facebook  |                     |       X       |                      |
| google    |          X          |       X       |           X          |
| github    |          X          | (may be null) |                      |
| linkedin  |                     |       X       |                      |

A big thank in advance to anyone contributing!



<a name="Acknowledgements"/>
#Acknowledgements

Undeniably, the package [accounts-merge](https://atmospherejs.com/package/accounts-merge) together with discussions directly entertained with its author @lirbank played a big role in writing this package. Actually at the very beginning accounts-meld was not even conceived as a package itself: only after a bit of googling around and various thinking the decision was taken, mainly because there was quite a bit of work involved and different projects might had different peculiar purposes.

Along the way also [accounts-multi] was released, basically as a consequence of [this](https://groups.google.com/forum/#!topic/meteor-talk/pfXfnX4qNzo) post.

So, big thanks to @lirbank, @dburles, and the original author of the snipped provided by him.

Many thanks also to everyone else which already provided, or will be, kind words, support, PR, suggestions and testing.



<a name="Documentation"/>
## Documentation

accounts-meld exploits a couple of server-side *hooks* to check email addresses associated with users' account. The aim is to permit different accounts belonging to the same user to be melded together in a unique account without losing any information associated with them. This means any field present inside the user objects as well as migrating all documents inside the database to the *surviving* account.



<a name="Logic"/>
### Logic
There are two different logic in place.

The first one checks all login attempts looking for other accounts with at least one verified email address in common. If one such email is found the two accounts will be elected for melding (see below). In case of a meld action, the *surviving* user account will be the one just logged in.

The second one permits the currently logged in user to add new services to its account: a call to `Meteor.loginWithSomething()` will be intercepted so to add the new service data to the current user object. In case another account using the same service associated with the same user id exists, the two accounts will be elected for melding (see below) and in case of a meld action is performed the *surviving* user account will be the currently logged in one. Although it is possible to add 3rd-party services to accounts created with classical sign-up flow (provided by `accounts-password`), at the moment it is **not** possible to do the contrary: a call to `Meteor.loginWithPassword` will log out the current user and login the one associated with the password service. After this, **only in case the email used with the password service is already verified**, the two account will be elected for melding (see below). In case of a meld action, the *surviving* user account will be the one originally associated with the password service.



<a name="Melding"/>
### Melding
Depending on the application, account-meld can be configured to automatically perform any possible accounts melding rather than let the user choose whether to meld or not to meld... This can be regulated with the configuration parameter [`askBeforeMeld`](#askBeforeMeld). In case you do not need automatic melding and want to let the user choose, some client-side template must be put in place. These are **not included** into accounts-meld for many reasons. The first one being for package size to be kept low and not to pollute the client with useless templates. While the most important one is every application has it's own logic, style and peculiarities: precooked client-side templates won't fit!

By the way, to get you up quickly as well as to show what could be done client-side, the package [accounts-meld-client-bootstrap](https://atmospherejs.com/package/accounts-meld-client-bootstrap), styled for bootstrap, allows for very basic user interaction.



<a name="PackageConfiguration"/>
### Package Configuration

There are some configuration options that can be used to customize the behaviour of account-meld. The only thing to do to configure your preferences is call `AccountsMeld.configure` within a server-side file. As an example, you could create the file `server/configuration/accounts_meld.js` containing the following:

```javascript
var meldDBCallback = function(src_user_id, dst_user_id){
    SomeCollection.update({user_id: src_user_id}, {$set: {user_id: dst_user_id}}, {multi: true});
};

AccountsMeld.configure({
    askBeforeMeld: true,
    meldDBCallback: meldDBCallback
});
```

to ask the client before melding accounts and migrating documents to the *surviving* account.

The package provides the following options:

* `askBeforeMeld` - optional Boolean, default false
* `checkForConflictingServices` - optional Boolean, default false
* `meldUserCallback` - optional function, default null
* `meldDBCallback` - optional function, default null
* `serviceAddedCallback` - optional function, default null


<a name="askBeforeMeld"/>
#### askBeforeMeld

This flags specifies whether accounts melding should be performed automatically without warning the user or not.

In case it is set to `false`, after every successful login attempt, if another account using the same verified email address is found, the two account are instantly melded in background without telling anything to the user.

In case it is set to `true`, every time a melding operation would be triggered, a new document containing melding details is inserted inside the collection `MeldActions`. This actually allows for server-client interaction eventually letting the user to choose whether to meld or not. See the section [MeldActions](#MeldActions) for more details.


#### checkForConflictingServices

This flags specifies whether another check is to be performed before to proceed with a melding operation. Specifically, the only (hopefully) weird case that can happen is having to meld *userA*

```javascript
{
    _id: 12345,
    services: {
        foobook: {
            id : 111,
            email: "email@example.com",
            ...
        },
        linkedout: {
            id : 222,
            email: "verified@domain.com",
            ...
        }
    }
}
```

with *userB*

```javascript
{
    _id: 67890,
    services: {
        foobook: {
            id : 333,
            email: "anotheremail@anotherdomain.com",
            ...
        },
        goggle: {
            id : 444,
            email: "verified@domain.com",
            ...
        }
    }
}
```

which share the same verified email with address `verified@domain.com`. We can be sure they belong to the same user, but the problem is they both have service data for the service foobook but referring to two different ids!
Although we might expect this is a very rare case, it might happen (and so it will standing to Murphy's law...).

By setting `checkForConflictingServices` to `true`, this particular case will be checked before performing the meld of the two user object. In case some conflict is found, the melding operation is simply cancelled without taking any further action. This means that the next time will be cancelled again or, in case `askBeforeMeld` was also set to `true`, the user will be prompted again with the choice to meld the two accounts.
...it might be that in the future this flow will be reorganized better!

In case you let `checkForConflictingServices` to `false` (default value) the meld operation which migrates *userA* to *userB* will result in *userB* having one more service (linkedout) and still foobook pointing to id 333:

```javascript
{
    _id: 67890,
    services: {
        foobook: {
            id : 333,
            email: "anotheremail@anotherdomain.com",
            ...
        },
        goggle: {
            id : 444,
            email: "verified@domain.com",
            ...
        },
        linkedout: {
            id : 222,
            email: "verified@domain.com",
            ...
        }
    }
}
```

Thing will continue to work! But the fact that both the user and the application will have lost a connection to foobook id: 111.

It mostly up to you judging whether this is bad or not...

#### meldUserCallback

One of the aim to accounts-meld is not to lose anything about any two melded accounts! But since the user object can be *personalized* differently by different applications it is very unlikely to have something suits everyone's needs.

This is why `meldUserCallback` let you specify a callback to deal with the two user object under melding. Below is an example about how to define such a callback.

```javascript
meldUserCallback = function(src_user, dst_user){
    // create a melded user object here and return it
    var meldedUser = _.clone(dst_user);
    // meldedUser.createdAt = src_user.createdAt;
    // ...

    return meldedUser;
};

AccountsMeld.configure({
    meldUserCallback: meldUserCallback
});
```

the two arguments passed in are the two objects fetched from `Meteor.users` which are going to be melded. `src_user` is the one that will be deleted while `dst_user` is the one which will *survive*.

And this is how it is called:

```javascript
var meldedUser = meldUserCallback(src_user, dst_user);
meldedUser = _.omit(meldedUser, '_id', 'services', 'emails', 'registered_emails');
_.each(meldedUser, function(value, key){
    dst_user[key] = value;
});
```

In particular the line

```javascript
meldedUser = _.omit(meldedUser, '_id', 'services', 'emails', 'registered_emails');
```

ensures that any accidental modification to sensitive fields will be neglected so not to hamper the functioning of the package and, in turn, of the application.


If no callback is provided the following default melding will be performed:

```javascript
    if (src_user.createdAt < dst_user.createdAt)
        dst_user.createdAt = src_user.createdAt;
    // 'profile' field
    var profile = {};
    _.defaults(profile, dst_user.profile || {});
    _.defaults(profile, src_user.profile || {});
    if (!_.isEmpty(profile))
        dst_user.profile = profile;
```

which could be fine in many cases...


#### meldDBCallback

Another callback not to lose anything can be provided (and should be) to let you change any reference to the `src_user._id` you might have inside your DB.
This is where you can migrate documents belonging to (or simply referencing) the user that will be deleted to the one that will *survive*.
The following code shows how to do it:

```javascript
var meldDBCallback = function(src_user_id, dst_user_id){
    // Here you can modify every collection you need for the document referencing
    // to src_user_id to be modified in order to point to dst_user_id
    SomeCollection.update(
        {user_id: src_user_id},
        {$set: {user_id: dst_user_id}},
        {multi: true}
    );
    AnotherCollection.update(
        {owner: src_user_id},
        {$set: {owner: dst_user_id}},
        {multi: true}
    );
};

AccountsMeld.configure({
    meldDBCallback: meldDBCallback
});
```

the two arguments passed in are the two ids associated with the source and destination users.

#### serviceAddedCallback

In case a new service is added to the current user object without the need of any meld action, the `serviceAddedCallback` can be used to update, e.g., the user profile.

*Warning: Since no particular checks are put in place, it is up to the developer not to modify sensible fields like 'services', 'emails', 'registered_emails', etc.*

The following code provides and example about how to pick up new information for the user profile from a newly added service:

```javascript
var serviceAddedCallback = function(user_id, service_name){
    if (service_name === 'foobook'){
        var user = Meteor.users.findOne(user_id);
        var link = user.services[service_name].link;
        if (link)
            Meteor.users.update(user_id, {$set: {"profile.fb_link": link}});
    }
};

AccountsMeld.configure({
    serviceAddedCallback: serviceAddedCallback
});
```


<a name="MeldActions"/>
### MeldActions

The package accounts-meld exports a collection called `MeldActions` which is used for client-server communication in case [`askBeforeMeld`](#askBeforeMeld) was set to `true`.

The collection content referencing to the currently signed in user is published under the name `pendingMeldActions`. So, to be able to access it, the client should subscribe with:

```javascript
Meteor.subscribe("pendingMeldActions");
```

For reading more about how to use it, please have a look at the beginning of the file [accounts-meld-server.js](https://github.com/splendido/meteor-accounts-meld/blob/master/lib/accounts-meld-server.js) where there are some more details about it. Differently you might also want to have a look at the source code of the package [accounts-meld-client-bootstrap](https://github.com/splendido/meteor-accounts-meld-client-bootstrap) and simply copy/paste what you need.



<a name="Ensure Everything Works"/>
## How to Ensure Everything Works as Expected

* Configure `accounts-password` to enforce email address validation (e.g. using some sign-up sign-in flow involving [`Accounts.sendVerificationEmail`](http://docs.meteor.com/#accounts_sendverificationemail)) and forbidding sign-in unless the email was verified)
* Use only 3rd-party services which grants you a way to check whether the email address was verified or not (e.g. not using those services allowing sign-in with non-verified emails, or exploiting some login hook like [`Accounts.validateLoginAttempt`](http://docs.meteor.com/#accounts_validateloginattempt) to check the email status by using some service specific API)
* If you use [aldeed:collection2](https://github.com/aldeed/meteor-collection2#attach-a-schema-to-meteorusers) on `Meteor.users`, you need to add the following field to your schema or you will get a collection2 exception each time a user logs in: ```registered_emails: { type: [Object], blackbox: true, optional: true }``` this comes from the use of `splendido:accounts-emails-field`, see the original mention to the need to extend the schema [here](https://github.com/splendido/meteor-accounts-emails-field#usage)



<a name="BehindTheScenes"/>
## Behind The Scenes

To intercept 3rd-party services log in attempts the function [`Accounts.updateOrCreateUserFromExternalService`](https://github.com/meteor/meteor/blob/devel/packages/accounts-base/accounts_server.js#L1102) is substituted with another one from accounts-meld which, in turn calls the original one (if need be). This is to allow adding new services to the currently signed in user.

Differently, the hook [`Accounts.onLogin`](http://docs.meteor.com/#accounts_onlogin), is used to register a callback to execute a check on registered emails after the user has been successfully logged in. In particular the field `registered_emails` provided by the package [accounts-emails-field](https://atmospherejs.com/package/accounts-emails-field) is exploited to look inside the collection `Meteor.users` whether there are other user objects having at least one validated email address in common with those associated (and validated) with the currently signed in user.
