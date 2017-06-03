AM = Artificial.Mummification
LOI = LandsOfIllusions

# Game representation of a human.
class LOI.HumanAvatar extends LOI.Avatar
  constructor: ->
    super
    
    dataNode = @dataNode()
    
    @body = LOI.Character.Part.Types.Body.create dataNode 'body'
    @outfit = LOI.Character.Part.Types.Body.create dataNode 'outfit'

  dataNode: -> throw new AE.NotImplementedException "You have to provide the data node for the avatar."
