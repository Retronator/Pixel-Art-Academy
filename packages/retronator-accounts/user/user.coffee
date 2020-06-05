AM = Artificial.Mummification
AB = Artificial.Babel
RA = Retronator.Accounts

class RA.User extends AM.Document
  @id: -> 'Retronator.Accounts.User'
  # username: user's username
  # emails: list of emails used to login with a password
  #   address: email address
  #   verified: is email address verified?
  # registered_emails: list of all emails across all login services
  #   address: email address
  #   verified: is email address verified?
  #   primary: should this email have priority over others for contact reasons?
  # contactEmail: auto-generated email where we can contact the user.
  # createdAt: time when user joined
  # profile: a custom object, writable by default by the client
  #   name: the name the user wants to display in the system
  # displayName: auto-generated system display name
  # publicName: auto-generated public name
  # services: array of authentication/linked service and their login tokens
  # loginServices: auto-generated array of service names that were added to services and can be used to login
  @Meta
    name: @id()
    collection: Meteor.users
    fields: =>
      contactEmail: Document.GeneratedField 'self', ['registered_emails', 'emails'], (user) ->
        contactEmail = null

        # Select the source of emails (in case registered email haven't been generated yet).
        emails = user.registered_emails or user.emails or []

        # First try to find a primary email.
        for email in emails
          if email.primary
            contactEmail = email.address
            break

        # Second try any verified email.
        unless contactEmail
          for email in emails
            if email.verified
              contactEmail = email.address
              break

        # Finally set just any email.
        contactEmail ?= emails[0]?.address or null

        [user._id, contactEmail]

      displayName: Document.GeneratedField 'self', ['username', 'profile', 'registered_emails'], (user) ->
        displayName = user.profile?.name or user.username or user.registered_emails?[0]?.address or ''
        [user._id, displayName]

      publicName: Document.GeneratedField 'self', ['profile'], (user) ->
        publicName = user.profile?.name or null
        [user._id, publicName]

      loginServices: [Document.GeneratedField 'self', ['services'], (user) ->
        availableServices = ['facebook', 'twitter', 'google', 'patreon']
        enabledServices = _.intersection _.keys(user.services), availableServices

        # Add password only if it has really been set (since the password key can also have just a reset token object).
        enabledServices.push 'password' if user.services?.password?.bcrypt

        [user._id, enabledServices]
      ]

      patreonId: Document.GeneratedField 'self', ['services'], (user) ->
        pateronId = user.services?.patreon?.id or null
        [user._id, pateronId]

      twitterScreenName: Document.GeneratedField 'self', ['services'], (user) ->
        twitterScreenName = user.services?.twitter?.screenName or null
        [user._id, twitterScreenName]

  @loginServicesForCurrentUser: 'Retronator.Accounts.User.loginServicesForCurrentUser'
  @twitterScreenNameForCurrentUser: @subscription 'twitterScreenNameForCurrentUser'
  @contactEmailForCurrentUser: 'Retronator.Store.User.contactEmailForCurrentUser'
  @registeredEmailsForCurrentUser: 'Retronator.Accounts.User.registeredEmailsForCurrentUser'
  
  @rename: 'Retronator.Accounts.User.rename'
  @sendVerificationEmail: 'Retronator.Accounts.User.sendVerificationEmail'
  @addEmail: 'Retronator.Accounts.User.addEmail'
  @removeEmail: 'Retronator.Accounts.User.removeEmail'
  @setPrimaryEmail: 'Retronator.Accounts.User.setPrimaryEmail'
  @sendPasswordResetEmail: 'Retronator.Accounts.User.sendPasswordResetEmail'
  @unlinkService: @method 'unlinkService'
