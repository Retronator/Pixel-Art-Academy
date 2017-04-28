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

  # Move user to the last location saved to the state. We do this only on load so that multiple players using
  # the same account can move independently, at least inside the current session (they will get synced again on
  # reload).
  LOI.adventure.currentLocationId state.currentLocationId

  return state
