LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Keycard extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Keycard'

  @fullName: -> "access keycard"
  @shortName: -> "keycard"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's your keycard to access different rooms in Retronator HQ. The Inventory page in the account folder holds more information.
    "

  @initialize()
