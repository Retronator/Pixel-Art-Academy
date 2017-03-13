Package.describe({
  name: 'retronator:retronator-accounts',
  version: '0.1.0'
});

Package.onUse(function(api) {
  api.use('retronator:retronator');
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
  api.use('benjick:stripe', 'server');
  api.use('jparker:crypto-aes');
  api.use('peerlibrary:directcollection');

  api.imply('accounts-password');
  api.imply('service-configuration');
  api.imply('email');

  api.export('Retronator');

  api.addFiles('retronator.coffee');
  api.addFiles('accounts.coffee');

  api.addFiles('main.import.styl', 'client', {isImport: true});

  // Helpers

  api.addFiles('spacebars.coffee', 'client');

  // Initialization

  api.addFiles('initialize-server/signin.coffee', 'server');
  api.addFiles('initialize-server/emails.coffee', 'server');

  // User
  
  api.addFiles('user/user.coffee');
  api.addFiles('user/methods.coffee');
  api.addFiles('user/methods-server.coffee', 'server');
  api.addFiles('user/subscriptions.coffee', 'server');

  // Components

  api.addFiles('components/components.coffee');

  api.addFiles('components/signin/signin.coffee');
  api.addFiles('components/signin/signin.html');
  api.addFiles('components/signin/signin.styl');

  // Pages
  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/admin/admin.html');
  api.addFiles('pages/admin/admin.coffee');

  api.addFiles('pages/admin/importusers/importusers.coffee');
  api.addFiles('pages/admin/importusers/importusers.html');
  api.addFiles('pages/admin/importusers/importusers.styl');
  api.addFiles('pages/admin/importusers/methods-server.coffee', 'server');

  api.addFiles('pages/admin/scripts/scripts.coffee');
  api.addFiles('pages/admin/scripts/scripts.html');
  api.addFiles('pages/admin/scripts/methods-server/importedusers-emailstolowercase.coffee', 'server');
  api.addFiles('pages/admin/scripts/methods-server/updatedocuments.coffee', 'server');
});
