AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Login extends AM.Component
  @register 'PixelArtAcademy.Pages.Login'

  onCreated: ->
    super

    # Redirect to account when sign in succeeded.
    @autorun =>
      if Meteor.userId() and LOI.characterId() and Roles.userIsInRole Meteor.userId(), 'alpha-access'
        # Run inside non-reactive to start a new reactivity context. This autorun will stop as soon as login is removed and
        # with it also all autoruns that would be run from withing this computation's context. Since we don't want to
        # control the execution of autoruns inside FlowRouter's trigger, we break the reactivity context.
        Tracker.nonreactive => FlowRouter.go 'home'

  characters: ->
    user = LOI.Accounts.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    user?.characters

  events: ->
    super.concat
      'click .load-character': @onClickLoadCharacter

  onClickLoadCharacter: (event) ->
    characterId = @currentData()._id
    LOI.Accounts.switchCharacter characterId
