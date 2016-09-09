Package.describe({
  name: 'retronator:accounts',
  version: '0.0.1'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.use('accounts-password');
  api.use('accounts-ui-unstyled');
  api.use('accounts-facebook');
  api.use('accounts-twitter');
  api.use('accounts-google');
  api.use('service-configuration');
  api.use('oauth-encryption');
  api.use('email');

  api.use('bozhao:link-accounts@1.2.9');
  api.use('splendido:accounts-meld@1.3.1');
  api.use('splendido:accounts-emails-field@1.2.0');
  api.use('benjick:stripe');

  api.imply('accounts-password');
  api.imply('service-configuration');

  api.export('Retronator');

  api.addFiles('retronator.coffee');
  api.addFiles('accounts.coffee');

  api.addFiles('initialize-server/signin.coffee', 'server');

  // Users

  // HACK: Add transactions namespace in advance so that PeerDB delayed initialization work correct.
  api.addFiles('transactions/transactions.coffee');

  api.addFiles('user/user.coffee');
  api.addFiles('user/methods.coffee');
  api.addFiles('user/subscriptions.coffee', 'server');
  api.addFiles('user/topsupporters.coffee', 'server');

  // Transactions

  api.addFiles('transactions/item/item.coffee');
  api.addFiles('transactions/item/subscriptions.coffee', 'server');

  api.addFiles('transactions/payment/payment.coffee');
  api.addFiles('transactions/payment/subscriptions.coffee', 'server');

  api.addFiles('transactions/transaction/transaction.coffee');
  api.addFiles('transactions/transaction/subscriptions.coffee', 'server');
  api.addFiles('transactions/transaction/toprecent.coffee', 'server');

  api.addFiles('transactions/transaction/methods-server/claim.coffee', 'server');
  api.addFiles('transactions/transaction/methods-server/createtransaction.coffee', 'server');
  api.addFiles('transactions/transaction/methods-server/emailcustomer.coffee', 'server');
  api.addFiles('transactions/transaction/methods-server/confirmation.coffee', 'server');
  api.addFiles('transactions/transaction/methods-server/stripe.coffee', 'server');

  api.addFiles('transactions/shoppingcart/shoppingcart.coffee');

  api.addFiles('transactions/stripe/client.coffee', 'client');
});
