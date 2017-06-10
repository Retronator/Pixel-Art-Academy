AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Array extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Array'

  onCreated: ->
    super

    @property = @data()
    
  parts: ->
    @property.parts()

  events: ->
    super.concat
      'click .avatar-part': @onClickAvatarPart

  onClickAvatarPart: (events) ->
    terminal = @ancestorComponentOfType C3.Design.Terminal

    terminal.screens.avatarPart.pushPart @property.part
