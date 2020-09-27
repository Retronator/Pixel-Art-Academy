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
    @initializeClient()

    @_call('/current_user').then (result) =>
      return unless result
      
      # Return the user.
      result.store.findAll('user')[0]?.serialize()

  @campaigns: ->
    @initializeClient()

    @_call('/current_user/campaigns').then (result) =>
      return unless result

      # Return all campaigns.
      result.store.findAll('campaign').map (campaign) => campaign.serialize()

  @pledges: (campaignId) ->
    @initializeClient()

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

    fieldsSuffix = "&fields%5Bpledge%5D=#{fields.join ','}"

    console.log "Retrieving Patreon pledges …"

    retrieve100Pledges = (link) =>
      @_call(link).then (result) =>
        return unless result

        # Get all pledges so far.
        pledges = result.store.findAll 'pledge'
        totalCount = result.rawJson.meta.count

        console.log "So far retrieved #{pledges.length} of #{totalCount} pledges."

        if pledges.length is totalCount
          # Return pledges with actual user data retrieved from the store.
          return _.map pledges, (pledge) =>
            pledge = pledge.serialize()

            userId = pledge.data.relationships.patron.data.id
            pledge.data.relationships.patron = result.store.find('user', userId).serialize()

            pledge

        # Make sure we didn't get more pledges than reported.
        throw new AE.InvalidOperationException "More pledges were retrieved than the total." if pledges.length > totalCount

        # We don't have all pledges yet, see if we have a link to the next.
        unless nextLink = result.rawJson.links.next
          throw new AE.InvalidOperationException "Next pledges link not found, but we don't have all pledges yet."

        # Fetch next 100. We need to remove the api link however.
        nextLink = nextLink.substring 'https://www.patreon.com/api/oauth2/api'.length
        retrieve100Pledges "#{nextLink}#{fieldsSuffix}"

    retrieve100Pledges "/campaigns/#{campaignId}/pledges?page%5Bcount%5D=100#{fieldsSuffix}"

  @_call: (url, dontRetry = false) ->
    # Call the Patreon API with the current client. Note that the client should be recreated between separate
    # (unconnected) requests since we can otherwise get forbidden access errors from the API. Only call this method in
    # succession (without calling initialize in between) when the store needs to retain its data (such as when paging
    # through pledges). This is also the reason why we don't always re-initialize it here, to allow connected calls.
    AT.Patreon._client(url).then (result) =>
      # Return result.
      result

    .catch (error) =>
      switch error.error.status
        when 401
          console.log "Patreon access token rejected."
          return if dontRetry

          # We need to refresh the access token.
          @refreshClient()

          # Repeat the call, but don't retry again if the call still fails to prevent infinite loops.
          @_call url, true

        else
          console.error "Error accessing Patreon API.", error.error.status
          
          # Return nothing.
          null

  class @Token extends AM.Document
    @id: -> 'Artificial.Telepathy.Patreon.Token'
    # accessToken: current API access token
    # refreshToken: current API refresh token
    @Meta
      name: @id()

Document.startup ->
  AT.Patreon.initializeClient()
