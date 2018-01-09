AM = Artificial.Mirage
AB = Artificial.Base
RA = Retronator.Accounts
AOA = Retropolis.City.Pages.AcademyOfArt

class AOA.Application extends AM.Component
  @register 'Retropolis.City.Pages.AcademyOfArt.Application'
  @version: -> "0.1.0"

  onCreated: ->
    super

    @applicationSuccessful = new ReactiveField false

    LOI.Character.forCurrentUser.subscribe @
    @subscribe RA.User.registeredEmailsForCurrentUser
    @subscribe RA.User.contactEmailForCurrentUser

    @selectedCharacterId = new ReactiveField LOI.characterId()

    @selectedCharacter = new ComputedField =>
      LOI.Character.documents.findOne @selectedCharacterId()
      
    @signIn = new LOI.Components.SignIn

  characters: ->
    user = Retronator.user()
    return unless user?.characters

    characters = for character in user.characters
      LOI.Character.documents.findOne character._id

    _.filter characters, (character) -> character?.activated

  events: ->
    super.concat
      'click .load-character-button': @onClickLoadCharacterButton
      'click .change-character-button': @onClickChangeCharacterButton
      'click .sign-in-button': @onClickSignInButton
      'click .sign-out-button': @onClickSignOutButton

  onClickLoadCharacterButton: (event) ->
    character = @currentData()
    @selectedCharacterId character._id

  onClickChangeCharacterButton: (event) ->
    @selectedCharacterId null

  onClickSignInButton: (event) ->
    @signIn.activatable.activate()

    # Wait till the user signs in or deactivates the sign in.
    @autorun (computation) =>
      if @signIn.activatable.deactivated()
        computation.stop()
        return

      return unless Meteor.userId()
      computation.stop()

      # Manually deactivate the dialog since it will not be rendered anymore.
      @signIn.activatable.deactivate()

  onClickSignOutButton: (event) ->
    Meteor.logout()

  class @Form extends AM.Component
    @register 'Retropolis.City.Pages.AcademyOfArt.Application.Form'

    onCreated: ->
      super

      @submitting = new ReactiveField false
      @applicationError = new ReactiveField false

      @applicationComponent = @ancestorComponentOfType AOA.Application

      # Subscribe to character's game state so we can detect if they already applied.
      @autorun (computation) =>
        return unless characterId = @applicationComponent.selectedCharacterId()
        LOI.GameState.forCharacter.subscribe @, characterId

      nameInputOptions =
        addTranslationText: => @translation "Add language variant"
        removeTranslationText: => @translation "Remove language variant"
        newTranslationLanguage: ''

      @fullNameInput = new LOI.Components.TranslationInput _.extend {}, nameInputOptions,
        placeholderText: => LOI.Character.Avatar.noNameTranslation()
        placeholderInTargetLanguage: true
        onTranslationInserted: (languageRegion, value) =>
          LOI.Character.updateName @applicationComponent.selectedCharacterId(), languageRegion, value

        onTranslationUpdated: (languageRegion, value) =>
          LOI.Character.updateName @applicationComponent.selectedCharacterId(), languageRegion, value

          # Return true to prevent the default update to be executed.
          true

    alreadyApplied: ->
      return unless gameState = LOI.GameState.documents.findOne 'character._id': @applicationComponent.selectedCharacterId()

      _.nestedProperty gameState, "state.things.#{PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionWeek.id()}.applied"

    renderFullNameInput: ->
      @fullNameInput.renderComponent @currentComponent()

    emails: ->
      options = [
      ]

      # Wait until the subscription to registered emails kicks in.
      return unless registeredEmails = Retronator.user()?.registered_emails

      for email in registeredEmails when email.verified
        options.push email.address

      options

    emailSelectedAttribute: ->
      emailOption = @currentData()

      # Select character's contact email or user's contact email if not set yet.
      contactEmail = @applicationComponent.selectedCharacter()?.contactEmail or Retronator.user()?.contactEmail

      'selected' if emailOption is contactEmail

    events: ->
      super.concat
        'click .apply-button': @onClickApplyButton

    onClickApplyButton: (event) ->
      event.preventDefault()

      contactEmail = @$('.email-selection').val()

      @applicationError null
      @submitting true

      PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionWeek.applyCharacter @applicationComponent.selectedCharacterId(), contactEmail, (error) =>
        @submitting false

        if error
          console.error error
          @applicationError error
          return

        @applicationComponent.applicationSuccessful true
