LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Components.Computer extends LOI.Adventure.Item
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  onCreated: ->
    super arguments...

    @currentScreen = new ReactiveField null
    @activeDialog = new ReactiveField null

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
        LOI.adventure.deactivateActiveItem()

  events: ->
    super(arguments...).concat
      'click .confirm-button': @onClickConfirmButton
      'click .cancel-button': @onClickCancelButton

  onClickConfirmButton: (event) ->
    @activeDialog().confirmAction()
    @activeDialog null

  onClickCancelButton: (event) ->
    @activeDialog null
