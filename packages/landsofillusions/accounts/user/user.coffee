LOI = LandsOfIllusions

class LandsOfIllusionsAccountsUser extends Document
  # username: user's username
  # emails: list of emails used to login with a password
  #   address: e-mail address
  #   verified: is e-mail address verified
  # registered_emails: list of all emails across all login services
  #   address: e-mail address
  #   verified: is e-mail address verified
  # createdAt: time when user joined
  # profile: a custom object, writable by default by the client
  #   name:
  # displayName: auto-generated display name
  # services: list of authentication/linked service and their login tokens
  # loginServices: auto-generated array of service names that were added to services and can be used to login
  # characters: list of characters the user has created, reverse of character.user
  #   _id
  #   name
  # roles: used for assigning roles and permissions
  # rewardTiers: list of reward tiers this user has
  #   _id
  #   name
  # rewards: list of rewards this user has
  #   _id
  #   name: manually copied from the rewards document
  #   description: manually copied from the rewards document
  #   claimed: boolean if the user has requested to claim the reward
  #   status: the current status of the claim
  # fundsBalance: available funds not claimed by rewards (can be negative)
  #
  @Meta
    name: 'LandsOfIllusionsAccountsUser'
    collection: Meteor.users
    fields: =>
      loginServices: [@GeneratedField 'self', ['services'], (fields) ->
        availableServices = ['password', 'facebook', 'twitter', 'google']
        enabledServices = _.intersection _.keys(fields.services), availableServices

        [fields._id, enabledServices]
      ]
      displayName: @GeneratedField 'self', ['username', 'profile', 'registered_emails'], (fields) ->
        displayName = fields.profile?.name or fields.username or fields.registered_emails?[0]?.address or ''
        [fields._id, displayName]

    triggers: =>
      updateBackerReward: @Trigger ['registered_emails'], (newDocument, oldDocument) ->
        user = newDocument

        # Don't do anything when document is removed.
        return unless user?._id

        try
          Meteor.call 'LandsOfIllusions.Accounts.updateRewards', user._id

        catch
          console.log "registered_emails has changed, but we're probably not on the LOI server."

LOI.Accounts.User = LandsOfIllusionsAccountsUser
