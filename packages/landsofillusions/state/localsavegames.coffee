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

  # Replace the game state locally. Do not use replaceGameState because that one starts a new game essentially
  # (destroys read-only state) and is meant to be used when the user wants to really overwrite their save state.
  _.extend LOI.adventure.gameState(), state
  LOI.adventure.gameState.updated()

  # Move user to the last location saved to the state. We do this only on load so that multiple players using
  # the same account can move independently, at least inside the current session (they will get synced again on
  # reload).
  LOI.adventure.setLocationId state.currentLocationId
  LOI.adventure.setTimelineId state.currentTimelineId

  return state
