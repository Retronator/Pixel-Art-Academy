LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Items.Terminal extends LOI.Adventure.Item
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  onCreated: ->
    super

    @currentScreen = new ReactiveField null
    @activeDialog = new ReactiveField null

    # Subscribe to all user's templates for the full duration of the terminal being open.
    LOI.Character.Part.Template.forCurrentUser.subscribe @

  switchToScreen: (screen) ->
    @currentScreen screen

  showDialog: (dialog) ->
    @activeDialog dialog

  backButtonCallback: ->
    =>
      # See if the current screen wants to perform a different action for the back button.
      currentScreen = @currentScreen()
      if currentScreen.backButtonCallback
        currentScreen.backButtonCallback()

      else if @activeDialog()
        # We're showing a dialog, so just cancel it.
        @activeDialog null

      else
        # None of the special cases occurred, close the terminal as usual.
        LOI.adventure.deactivateCurrentItem()

  events: ->
    super.concat
      'click .confirm-button': @onClickConfirmButton
      'click .cancel-button': @onClickCancelButton

  onClickConfirmButton: (event) ->
    @activeDialog().confirmAction()
    @activeDialog null

  onClickCancelButton: (event) ->
    @activeDialog null
