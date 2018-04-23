LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Settings.ConsentField
  constructor: (@options) ->
    storedValue = new ReactiveField

    AM.PersistentStorage.persist
      field: storedValue
      storageKey: "LandsOfIllusions.Settings.#{@options.name}"

    # Read initial values from local storage, if present.
    @allowed = new ReactiveField storedValue() or false
    @decided = new ReactiveField storedValue()?

    # Update stored value.
    Tracker.autorun (computation) =>
      # Allowed will be either true or false.
      value = @allowed()

      # If we're not allowed to store the value, we set it to undefined, which will clear it from local storage.
      # If the value is true however, we still store it as the consent to allow this particular field implies they
      # want this to stay persisted in the future.
      value = undefined unless @options.persistDecision?.allowed() or value

      storedValue value

  allow: (value = true) ->
    @allowed value is true
    @decided true

  disallow: ->
    @allowed false
    @decided true

  showDialog: (callback) ->
    dialog = new LOI.Components.Dialog
      message: @options.question
      moreInfo: @options.moreInfo
      buttons: [
        text: "Yes"
        value: true
      ,
        text: "No"
      ]

    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        value = dialog.result is true

        @allow value
        callback? value
