AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.OneOf extends C3.Design.Terminal.Properties.Property
  @register 'SanFrancisco.C3.Design.Terminal.Properties.OneOf'

  avatarPartPreviewOptions: ->
    rendererOptions:
      renderingSides: [LOI.Engine.RenderingSides.Keys.Front]

  events: ->
    super(arguments...).concat
      'click .avatar-part': @onClickAvatarPart

  onClickAvatarPart: (events) ->
    property = @data()
    terminal = @ancestorComponentOfType C3.Design.Terminal

    terminal.screens.avatarPart.pushPart property.part
