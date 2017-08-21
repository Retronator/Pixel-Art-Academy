LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Stasis.ControlPanel extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.C3.Stasis.ControlPanel'
  @fullName: -> "control panel"
  @shortName: -> "panel"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      Each vat has a control panel in front of it. You can use the panel to activate agents.
    "

  @initialize()
