LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Items.Terminal extends LOI.Components.Computer
  onCreated: ->
    super

    # Subscribe to all user's templates for the full duration of the terminal being open.
    LOI.Character.Part.Template.forCurrentUser.subscribe @
