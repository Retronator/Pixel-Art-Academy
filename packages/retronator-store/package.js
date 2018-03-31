Package.describe({
  name: 'retronator:retronator-store',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'validate-vat': '0.5.1'
});

Package.onUse(function(api) {
  api.use('retronator:retronator');
  api.use('retronator:artificialengines');
  api.use('retronator:retronator-accounts');
  api.use('chfritz:easycron');
  api.use('peerlibrary:xml2js');

  api.export('Retronator');

  api.addFile('store');

  // User

  api.addFile('user/user');
  api.addFile('user/methods');
  api.addServerFile('user/subscriptions');
  api.addServerFile('user/topsupporters');

  // Item

  api.addFile('item/item');
  api.addServerFile('item/subscriptions');

  api.addServerFile('item/migrations/0000-renamecollection');

  // VAT

  api.addFile('vat..');
  api.addServerFile('vat/methods-server');
  api.addFile('vat/rates');
  api.addFile('vat/exchangerate..');
  api.addServerFile('vat/exchangerate/server');
  api.addServerFile('vat/exchangerate/methods-server');

  // Payment

  api.addFile('payment/payment');
  api.addServerFile('payment/subscriptions');

  api.addServerFile('payment/migrations/0000-renamecollection');
  api.addServerFile('payment/migrations/0001-migratestripecustomeridfield');
  api.addServerFile('payment/migrations/0002-invalid');

  // Payment method

  api.addFile('paymentmethod/paymentmethod');
  api.addServerFile('paymentmethod/subscriptions');

  api.addServerFile('paymentmethod/methods-server/stripe');

  // Transaction

  api.addFile('transaction/transaction');
  api.addServerFile('transaction/subscriptions');
  api.addServerFile('transaction/toprecent-server');

  api.addServerFile('transaction/methods-server/claim');
  api.addServerFile('transaction/methods-server/createtransaction');
  api.addServerFile('transaction/methods-server/emailcustomer');
  api.addServerFile('transaction/methods-server/confirmation');
  api.addServerFile('transaction/methods-server/stripe');

  api.addServerFile('transaction/migrations/0000-renamecollection');
  api.addServerFile('transaction/migrations/0001-invalid');

  api.addFile('shoppingcart/shoppingcart');

  // Add item document types. They need to be available on server and client for casting purposes.
  api.addFile('items/items');
  api.addFile('items/catalogkeys');
  api.addFile('items/bundles/bundles');

  api.addFile('items/bundles/pixelartacademy/kickstarter/tier');
  api.addFile('items/bundles/pixelartacademy/kickstarter/alphaaccess');
  api.addFile('items/bundles/pixelartacademy/kickstarter/basicgame');
  api.addFile('items/bundles/pixelartacademy/kickstarter/fullgame');

  api.addFile('items/bundles/pixelartacademy/preorder/upgrade');
  api.addFile('items/bundles/pixelartacademy/preorder/avatareditor');
  api.addFile('items/bundles/pixelartacademy/preorder/alphaaccess');

  // Initialization

  // First create all the items.
  api.addServerFile('initialize-server/items/landsofillusions/landsofillusions');
  api.addServerFile('initialize-server/items/retropolis/retropolis');
  api.addServerFile('initialize-server/items/retronator/retronator');
  api.addServerFile('initialize-server/items/pixelartacademy/pixelartacademy');
  api.addServerFile('initialize-server/items/pixelartacademy/kickstarter/keycards');

  // Then create the bundles of items.
  api.addServerFile('initialize-server/items/bundles/bundles');

  // Then finish with other initialization.
  api.addServerFile('initialize-server/admin');
  api.addServerFile('initialize-server/test');

  api.addServerFile('patreon/server');

  // Components

  api.addFile('components..');

  api.addComponent('components/bundleitem..');
  api.addComponent('components/topsupporters..');
  api.addComponent('components/invoice..');

  // Pages
  api.addFile('pages..');
  api.addComponent('pages/invoice..');

  api.addUnstyledComponent('pages/admin..');

  api.addUnstyledComponent('pages/admin/scripts..');
  api.addServerFile('pages/admin/scripts/methods-server/convertpreorders');
  api.addServerFile('pages/admin/scripts/methods-server/convertimportedusers');
  api.addServerFile('pages/admin/scripts/methods-server/user-ontransactionsupdated');

  api.addUnstyledComponent('pages/admin/authorizedpayments..');
  api.addServerFile('pages/admin/authorizedpayments/methods-server');

  api.addUnstyledComponent('pages/admin/patreon..');
  api.addServerFile('pages/admin/patreon/methods-server');

  api.addComponent('pages/admin/vat..');

});
