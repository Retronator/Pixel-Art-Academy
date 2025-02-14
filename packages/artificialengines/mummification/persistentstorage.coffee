AE = Artificial.Everywhere
AM = Artificial.Mummification

# Storing helper for localStorage and sessionStorage.
class AM.PersistentStorage
  @persist: (options) ->
    options.storage ?= localStorage
    options.tracker ?= Tracker

    throw new AE.ArgumentNullException 'Storage key must be provided.' unless options.storageKey?
    throw new AE.ArgumentNullException 'Reactive field must be provided.' unless options.field?

    # Load the current state from local storage.
    storedState = options.storage.getItem options.storageKey

    options.field EJSON.parse storedState if storedState and storedState isnt 'undefined'

    # Start listening for state changes. We are also returning the autorun handle, since this is the last line.
    options.tracker.autorun (computation) =>
      # Register dependency.
      state = options.field()

      # If we provide a consent field, query it to see if we allow storage.
      state = undefined if options.consentField and not options.consentField()

      if state is undefined
        # Remove the state from storage.
        options.storage.removeItem options.storageKey

      else
        # Store the new state into storage.
        encodedValue = EJSON.stringify state
        options.storage.setItem options.storageKey, encodedValue
