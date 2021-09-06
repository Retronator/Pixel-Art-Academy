/* global AccountsEmailsField: false */
'use strict';


// Register `updateEmails` function under the `onLogin` hook so to
// check/update the `emails` field at every new login!
Accounts.onLogin(AccountsEmailsField.updateEmails);
