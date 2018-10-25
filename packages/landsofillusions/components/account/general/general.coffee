AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.General extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.General'
  @url: -> 'registration'
  @displayName: -> 'Registration'

  @initialize()

  onCreated: ->
    super arguments...

    @subscribe RA.User.registeredEmailsForCurrentUser
    @subscribe RA.User.contactEmailForCurrentUser
    
  user: ->
    Retronator.user
      fields:
        registered_emails: 1
        contactEmail: 1

  emailsCount: ->
    @user()?.registered_emails?.length or 0

  emptyLines: ->
    emailsCount = @emailsCount()
    return if emailsCount >= 4

    # Return an array with enough elements to pad the emails table to 5 rows (one is added for inserting new email).
    '' for i in [emailsCount...4]

  primaryCheckedAttribute: ->
    email = @currentData()

    'checked' if email.address is @user().contactEmail

  hasUnverifiedEmails: ->
    unverifiedEmails = _.filter @user().registered_emails, (email) => not email.verified

    unverifiedEmails.length

  # Events

  events: ->
    super(arguments...).concat
      'click .verify-email-button': @onClickVerifyEmail
      'change .address-input': @onChangeAddressInput
      'change .primary-input': @onChangePrimaryInput

  onClickVerifyEmail: (event) ->
    email = @currentData()

    Meteor.call RA.User.sendVerificationEmail, email.address, (error) =>
      if error
        message = "Whoops, something went wrong with sending the verification email. Please email me at hi@retronator.com to resolve this."

      else
        message = "A verification email has been sent to #{email.address}. Click the link in the email to complete verification."

      LOI.adventure.showActivatableModalDialog
        dialog: new LOI.Components.Dialog
          message: message
          buttons: [
            text: "OK"
          ]

  onChangeAddressInput: (event) ->
    email = @currentData()

    oldAddress = email?.address or null
    newAddress = @$(event.target).val()

    Meteor.call RA.User.removeEmail, oldAddress if oldAddress

    if newAddress.length
      Meteor.call RA.User.addEmail, newAddress, (error) =>
        if error
          message = "Something went wrong with adding the email. #{error.message}"

        else
          message = "Email added. Please verify it by clicking the red verified field next to it."

        LOI.adventure.showActivatableModalDialog
          dialog: new LOI.Components.Dialog
            message: message
            buttons: [
              text: "OK"
            ]

    # Also clear new address input, since we've processed it (or it was already empty, so this is a nop).
    @$('.new-address-input').val('')

  onChangePrimaryInput: (event) ->
    primaryAddress = @$('.primary-input:checked').val()

    Meteor.call RA.User.setPrimaryEmail, primaryAddress

  # Components

  class @Username extends AM.DataInputComponent
    @register 'LandsOfIllusions.Components.Account.General.Username'

    onCreated: ->
      super arguments...

      @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

    load: ->
      user = RA.User.documents.findOne Meteor.userId(),
        fields:
          'profile.name': 1

      user?.profile?.name

    save: (value) ->
      Meteor.call "Retronator.Accounts.User.rename", value

    placeholder: ->
      AB.translate(@_userBabelSubscription, 'Anonymous').text
