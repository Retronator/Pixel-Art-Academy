AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.OneOf extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.OneOf'

  onCreated: ->
    super

    @property = @data()

  events: ->
    super.concat
      'click .avatar-part': @onClickAvatarPart

  onClickAvatarPart: (events) ->
    terminal = @ancestorComponentOfType C3.Design.Terminal

    terminal.screens.avatarPart.pushPart @property.part
