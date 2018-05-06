AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.AdvertisedContextListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    # Relay query to advertised context's special handler.
    return unless context = LOI.adventure.advertisedContext()
    context.onCommandWhileAdvertised commandResponse
