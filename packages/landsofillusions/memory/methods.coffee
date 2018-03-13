LOI = LandsOfIllusions

LOI.Memory.insert.method ->
  # Only players can create memories.
  LOI.Authorize.player()

  LOI.Memory.documents.insert {}
