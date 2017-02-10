LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Terrace.VendingMachine extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terrace.VendingMachine'
  @fullName: -> "vending machine"
  @description: ->
    "
      It seems to dispense beverages.
    "

  @initialize()
