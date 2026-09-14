AT = Artificial.Telepathy
AM = Artificial.Mummification

# Patreon API wrapper.
class AT.Patreon
  @apiUrl = 'https://www.patreon.com/api/oauth2/v2'
  @userAgent = 'Pixel Art Academy - Patreon Sync'

  @initializeClient: ->
    if tokenData = @Token.documents.findOne()
      @_accessToken = tokenData.accessToken
      @initialized = true

  @refreshClient: (refreshToken) ->
    unless refreshToken
      # Get refresh token from database.
      tokenData = @Token.documents.findOne()
      refreshToken = tokenData?.refreshToken

    unless refreshToken
      console.error "Could not refresh Patreon API client: refresh token is missing."
      return

    patreonSettings = Meteor.settings.patreon

    unless patreonSettings?.clientId and patreonSettings?.clientSecret
      console.error "Could not refresh Patreon API client: client ID or secret is missing from settings."
      return

    console.log "Attempting Patreon API client refresh ..."

    # Exchange refresh token for a new access token.
    tokenResponseData = @_requestTokens
      grant_type: 'refresh_token'
      client_id: patreonSettings.clientId
      client_secret: OAuth.openSecret(patreonSettings.clientSecret)
      refresh_token: refreshToken

    unless tokenResponseData?.access_token
      console.error "Could not refresh Patreon API client: Patreon returned no access token."
      return

    accessToken = tokenResponseData.access_token
    refreshToken = tokenResponseData.refresh_token

    # Save tokens to database in case the server restarts.
    @Token.documents.upsert {}, {accessToken, refreshToken}

    @_accessToken = accessToken

    console.log "Refreshed Patreon API client with token."

    @initialized = true

  @exchangeAuthorizationCode: (code, clientId, clientSecret, redirectUri) ->
    @_requestTokens
      code: code
      client_id: clientId
      client_secret: clientSecret
      grant_type: 'authorization_code'
      redirect_uri: redirectUri

  @currentUser: (accessToken) ->
    @_call('/identity',
      accessToken: accessToken
      params:
        'fields[user]': 'email'
    ).then (responseData) =>
      responseData?.data

  @campaigns: ->
    @_call('/campaigns').then (responseData) =>
      responseData?.data

  @members: (campaignId) ->
    memberFields = [
      'campaign_lifetime_support_cents'
      'currently_entitled_amount_cents'
      'email'
      'last_charge_date'
      'patron_status'
      'pledge_relationship_start'
    ]

    members = []

    console.log "Retrieving Patreon campaign members …"

    retrieveMembersPage = (nextCursor) =>
      requestParameters =
        include: 'user'
        'fields[member]': memberFields.join ','
        'page[count]': 1000

      requestParameters['page[cursor]'] = nextCursor if nextCursor

      @_call("/campaigns/#{campaignId}/members", params: requestParameters).then (responseData) =>
        return unless responseData

        members = members.concat responseData.data

        totalMemberCount = responseData.meta?.pagination?.total
        console.log "So far retrieved #{members.length} of #{totalMemberCount} Patreon campaign members."

        # Patreon API v2 uses cursor-based pagination. Continue until the next cursor is null or omitted.
        nextCursor = responseData.meta?.pagination?.cursors?.next
        return members unless nextCursor

        retrieveMembersPage nextCursor

    retrieveMembersPage()

  @_call: (path, options = {}, dontRetry = false) ->
    @initializeClient() unless options.accessToken or @_accessToken

    accessToken = options.accessToken or @_accessToken

    # Resolve synchronous Meteor HTTP calls through a promise to preserve the asynchronous wrapper interface.
    Promise.resolve().then =>
      response = HTTP.get "#{@apiUrl}#{path}",
        headers:
          Accept: 'application/json'
          Authorization: "Bearer #{accessToken}"
          'User-Agent': @userAgent
        params: options.params

      responseData = @_parseResponseData response

      unless responseData
        contentType = response.headers?['content-type']
        console.error "Patreon API returned a response that could not be parsed as JSON.", response.statusCode, contentType

      responseData

    .catch (error) =>
      statusCode = error.response?.statusCode or error.statusCode or error.error?.status

      switch statusCode
        when 401
          console.log "Patreon access token rejected."
          return if dontRetry or options.accessToken

          # We need to refresh the access token.
          @refreshClient()

          # Repeat the call, but don't retry again if the call still fails to prevent infinite loops.
          @_call path, options, true

        else
          console.error "Error accessing Patreon API.", statusCode, error
          
          # Return nothing.
          null

  @_requestTokens: (requestParameters) ->
    # Patreon requires OAuth token parameters as URL-encoded form data instead of a JSON request body.
    requestContent = ("#{encodeURIComponent key}=#{encodeURIComponent value}" for key, value of requestParameters).join '&'

    response = HTTP.post 'https://www.patreon.com/api/oauth2/token',
      headers:
        Accept: 'application/json'
        'Content-Type': 'application/x-www-form-urlencoded'
        'User-Agent': @userAgent
      content: requestContent

    @_parseResponseData response

  @_parseResponseData: (response) ->
    # Meteor only populates response.data for a small set of JSON content types, so parse JSON:API content ourselves.
    return response.data if response.data?

    try
      JSON.parse response.content

    catch error
      null

  class @Token extends AM.Document
    @id: -> 'Artificial.Telepathy.Patreon.Token'
    # accessToken: current API access token
    # refreshToken: current API refresh token
    @Meta
      name: @id()

Document.startup ->
  AT.Patreon.initializeClient()
