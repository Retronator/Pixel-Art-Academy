Package.describe({
  name: 'retronator:store',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:retronator');
  api.use('retronator:accounts');

  api.export('Retronator');

  api.addFiles('store.coffee');

  // HACK: Add transactions namespace in advance so that PeerDB delayed initialization work correct.
  api.addFiles('transactions/transactions.coffee');

  // User

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

  // Add item document types. They need to be available on server and client for casting purposes.
  api.addFiles('items/items.coffee');
  api.addFiles('items/catalogkeys.coffee');
  api.addFiles('items/bundles/bundles.coffee');

  api.addFiles('items/bundles/pixelartacademy/kickstarter/tier.coffee');
  api.addFiles('items/bundles/pixelartacademy/kickstarter/alphaaccess.coffee');
  api.addFiles('items/bundles/pixelartacademy/kickstarter/basicgame.coffee');
  api.addFiles('items/bundles/pixelartacademy/kickstarter/fullgame.coffee');

  api.addFiles('items/bundles/pixelartacademy/preorder/upgrade.coffee');
  api.addFiles('items/bundles/pixelartacademy/preorder/avatareditor.coffee');
  api.addFiles('items/bundles/pixelartacademy/preorder/foundationyear.coffee');

  // Initialization

  // First create all the items.
  api.addFiles('initialize-server/items/retronator/retronator.coffee', 'server');
  api.addFiles('initialize-server/items/landsofillusions/landsofillusions.coffee', 'server');
  api.addFiles('initialize-server/items/retropolis/retropolis.coffee', 'server');
  api.addFiles('initialize-server/items/pixelartacademy/pixelartacademy.coffee', 'server');
  api.addFiles('initialize-server/items/pixelartacademy/kickstarter/keycards.coffee', 'server');

  // Then create the bundles of items.
  api.addFiles('initialize-server/items/bundles/bundles.coffee', 'server');

  // Then finish with other initialization.
  api.addFiles('initialize-server/admin.coffee', 'server');
  api.addFiles('initialize-server/test.coffee', 'server');
  api.addFiles('initialize-server/peerdb.coffee', 'server');

  // Layouts

  api.addFiles('layouts/layouts.coffee');

  api.addFiles('layouts/store/store.coffee');
  api.addFiles('layouts/store/store.html');
  api.addFiles('layouts/store/store.styl');
  
  // Components

  api.addFiles('components/components.coffee');

  api.addFiles('components/bundleitem/bundleitem.coffee');
  api.addFiles('components/bundleitem/bundleitem.html');
  api.addFiles('components/bundleitem/bundleitem.styl');

  api.addFiles('components/topsupporters/topsupporters.coffee');
  api.addFiles('components/topsupporters/topsupporters.html');
  api.addFiles('components/topsupporters/topsupporters.styl');

  // Pages

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/store/store.coffee');
  api.addFiles('pages/store/store.html');
  api.addFiles('pages/store/store.styl');

  api.addFiles('pages/cart/cart.coffee');
  api.addFiles('pages/cart/cart.html');
  api.addFiles('pages/cart/cart.styl');

  api.addFiles('pages/checkout/checkout.coffee');
  api.addFiles('pages/checkout/checkout.html');
  api.addFiles('pages/checkout/checkout.styl');

  api.addFiles('pages/claim/claim.coffee');
  api.addFiles('pages/claim/claim.html');
  api.addFiles('pages/claim/claim.styl');

  api.addFiles('pages/money/money.coffee');
  api.addFiles('pages/money/money.html');
  api.addFiles('pages/money/money.styl');

  api.addFiles('pages/inventory/inventory.coffee');
  api.addFiles('pages/inventory/inventory.html');
  api.addFiles('pages/inventory/inventory.styl');

  api.addFiles('pages/account/account.coffee');
  api.addFiles('pages/account/account.html');
  api.addFiles('pages/account/account.styl');

  // Typography

  api.addFiles('typography/typography.css', 'client');
  api.addFiles('typography/typography.import.styl', 'client', {isImport:true});

  // Styles

  api.addFiles('styles/console.import.styl', 'client', {isImport:true});
});
