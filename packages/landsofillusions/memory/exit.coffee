AB = Artificial.Babel
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

# A dummy location for exiting a memory.
class LOI.Memory.Exit extends LOI.Adventure.Location
  @id: -> 'LandsOfIllusions.Memory.Exit'
  @region: -> null

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "memory exit"
  @shortName: -> "exit"
  @description: ->
    "
      It's a way out of the memory.
    "
