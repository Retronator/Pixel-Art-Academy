FM = FataMorgana
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.InputDialog extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.InputDialog'
  @register @id()

  # options:
  #   prompt: string or function that provides the text to display in the dialog
  #   value: optional initial value of the input field
  #   maxLength: optional maximum length of typed text in the input field
  #   [buttons]:
  #     text: string or function that provides the text to display on the button
  #     value: the return value if this button is pressed
  #     cancel: true if this button should be used to cancel the dialog
  #   onClose: a callback that is called when the dialog is closed
  @createInterfaceData: (options = {}) ->
    contentComponentId: @id()
    contentComponentData: _.defaults {}, options,
      value: ''
      buttons: [
        text: "OK"
        value: true
      ,
        text: "Cancel"
        value: false
        cancel: true
      ]
    canDismiss: false
    left: 0
    right: 0
    top: 0
    bottom: 0

  onRendered: ->
    super arguments...

    input = @$('.input')[0]
    input.focus()
    input.select()

  prompt: ->
    options = @data()
    _.resolve options.prompt

  onBackButton: ->
    options = @data()
    return unless cancelButton = _.find options.buttons, (button) => button.cancel
    @_processButton cancelButton
    
    # Inform that we've handled the back button.
    true
    
  _processButton: (button) ->
    options = @data()
    
    result =
      buttonValue: button.value
      inputValue: @$('.input').val()

    @closeDialog()
    
    options.onClose? result

  events: ->
    super(arguments...).concat
      'click .dialog-button': @onClickDialogButton

  onClickDialogButton: (event) ->
    button = @currentData()
    @_processButton button
