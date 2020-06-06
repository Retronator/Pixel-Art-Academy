AE = Artificial.Everywhere
RA = Retronator.Accounts

Crypto = require 'crypto'

WebApp.connectHandlers.use '/patreon/webhook', (request, response, next) =>
  unless request.method is 'POST'
    response.writeHead 400
    response.end()
    return

  headerSignature = request.headers['x-patreon-signature']

  unless headerSignature
    response.writeHead 400
    response.end()
    return

  hmac = Crypto.createHmac 'sha256', Meteor.settings.patreon.webhookSecret

  # Receive the body of the post message.
  request.on 'data', Meteor.bindEnvironment (data) =>
    hmac.update data

  request.on 'end', Meteor.bindEnvironment =>
    calculatedSignature = hmac.digest 'hex'
    console.log "Patreon webhook invoked."
    console.log "Header signature:", headerSignature
    console.log "Calculated signature", calculatedSignature

    response.writeHead 204
    response.end()

    return unless calculatedSignature is headerSignature

    # This looks like a genuine request from Patreon. Update all pledges.
    RA.Patreon.updateCurrentPledges()
