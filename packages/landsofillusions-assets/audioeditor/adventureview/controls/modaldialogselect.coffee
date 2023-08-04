AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AdventureView.ModalDialogSelect extends AM.DataInputComponent
  @register 'LandsOfIllusions.Assets.AudioEditor.AdventureView.ModalDialogSelect'

  constructor: ->
    super arguments...

    @type = AM.DataInputComponent.Types.Select

  onCreated: ->
    super arguments...

    @adventureView = @ancestorComponentOfType LOI.Assets.AudioEditor.AdventureView

  options: ->
    options = for componentClass in AM.Component.getClasses()
      name = componentClass.componentName()
      
      name: name
      value: name

    options = _.sortBy options, 'value'

    # Add the empty option.
    options.unshift
      name: ''
      value: null

    options

  load: ->
    @adventureView.modalDialogComponentName()

  save: (value) ->
    @adventureView.modalDialogComponentName value
