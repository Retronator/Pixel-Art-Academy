AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.OneOf extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.OneOf'

  events: ->
    super.concat
      'click .avatar-part': @onClickAvatarPart

  onClickAvatarPart: (events) ->
    property = @data()
    terminal = @ancestorComponentOfType C3.Design.Terminal

    terminal.screens.avatarPart.pushPart property.part
