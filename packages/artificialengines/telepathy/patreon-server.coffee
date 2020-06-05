AE = Artificial.Everywhere
AT = Artificial.Telepathy
AM = Artificial.Mummification

PatreonAPI = require 'patreon'

# Patreon API wrapper.
class AT.Patreon
  @initializeClient: ->
    if tokenData = @Token.documents.findOne()
      @_client = PatreonAPI.patreon tokenData.accessToken
      @initialized = true

  @refreshClient: (refreshToken) ->
    unless refreshToken
      # Get refresh token from database.
      tokenData = @Token.documents.findOne()
      refreshToken = tokenData.refreshToken

    console.log "Attempting Patreon API client refresh ..."

    # Exchange refresh token for a new access token.
    tokenResponse = HTTP.post 'https://www.patreon.com/api/oauth2/token', params:
      grant_type: 'refresh_token'
      client_id: Meteor.settings.patreon.clientId
      client_secret: OAuth.openSecret(Meteor.settings.patreon.clientSecret)
      refresh_token: refreshToken

    accessToken = tokenResponse.data.access_token
    refreshToken = tokenResponse.data.refresh_token

    # Save tokens to database in case the server restarts.
    @Token.documents.upsert {}, {accessToken, refreshToken}

    @_client = PatreonAPI.patreon accessToken

    console.log "Refreshed Patreon API client with token."

    @initialized = true

  @currentUser: ->
    @_call('/current_user').then (result) =>
      # Return the user.
      result.store.findAll('user')[0]?.serialize()

  @campaigns: ->
    @_call('/current_user/campaigns').then (result) =>
      # Return all campaigns.
      result.store.findAll('campaign').map (campaign) => campaign.serialize()

  @pledges: (campaignId) ->
    fields = [
      'amount_cents'
      'created_at'
      'declined_since'
      'pledge_cap_cents'
      'patron_pays_fees'
      'total_historical_amount_cents'
      'is_paused'
      'has_shipping_address'
    ]

    # TODO: Update when we have more than 1000 patrons.
    @_call("/campaigns/#{campaignId}/pledges?page%5Bcount%5D=1000&fields%5Bpledge%5D=#{fields.join ','}").then (result) =>
      # Return all pledges.
      result.store.findAll('pledge').map (pledge) =>
        pledge = pledge.serialize()

        # Insert actual user data.
        userId = pledge.data.relationships.patron.data.id
        pledge.data.relationships.patron = result.store.find('user', userId).serialize()

        pledge

  @_call: (url) ->
    AT.Patreon._client(url).then (result) =>
      # Return result.
      result

    .catch (error) =>
      switch error.error.status
        when 401
          # We need to refresh the access token.
          @refreshClient()

          # Repeat the call.
          @_call url

        else
          console.error "Error accessing Patreon API.", error
          
          # Return nothing
          null

  class @Token extends AM.Document
    @id: -> 'Artificial.Telepathy.Patreon.Token'
    # accessToken: current API access token
    # refreshToken: current API refresh token
    @Meta
      name: @id()

Document.startup ->
  AT.Patreon.initializeClient()
