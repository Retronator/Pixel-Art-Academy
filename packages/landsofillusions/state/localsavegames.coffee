AM = Artificial.Mummification
LOI = LandsOfIllusions

LOI.save = (slot) ->
  # Store the game state into storage.
  state = LOI.adventure.gameState()
  encodedValue = EJSON.stringify state

  localStorage.setItem "LandsOfIllusions.Adventure.save.#{slot}", encodedValue

  return state

LOI.load = (slot) ->
  encodedValue = localStorage.getItem "LandsOfIllusions.Adventure.save.#{slot}"

  unless encodedValue
    console.error "Save slot is empty."
    return

  state = EJSON.parse encodedValue
  LOI.adventure.replaceGameState state

  return state
