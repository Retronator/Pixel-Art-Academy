AE = Artificial.Everywhere
AT = Artificial.Telepathy

PatreonAPI = Npm.require 'patreon'

# Patreon API wrapper.
class AT.Patreon
  if Meteor.settings.patreon
    @_client = PatreonAPI.patreon Meteor.settings.patreon.creatorAccessToken

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
      'outstanding_payment_amount_cents'
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
      result

    .catch (error) =>
      console.error "Error accessing Patreon API.", error
      throw error
