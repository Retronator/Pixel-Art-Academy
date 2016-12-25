AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Adventure.Parser
  constructor: (@options) ->
    # Set Vocabulary shorthand.
    @Vocabulary = LOI.Adventure.Parser.Vocabulary

    # Make a new vocabulary instance.
    @vocabulary = new @Vocabulary

  destroy: ->
    @vocabulary.destroy()

  ready: ->
    @vocabulary.ready()

  parse: (command) ->
    # Create a rich command object.
    command = new LOI.Adventure.Parser.Command command

    # Get the current location. Parse is not reactive so it's OK to save it 
    # statically like that. It is only used in subsequent parse subroutines.
    @location = @options.adventure.currentLocation()

    # Track with analytics. Save the command as action and location as label.
    eventCategory = 'Adventure Command'
    eventAction = command.normalizedCommand
    eventLabel = @location.id()

    ga 'send', 'event', eventCategory, eventAction, eventLabel

    return if @parseDebug command
    return if @parseNavigation command
    return if @parseAbilities command
    return if @parseDescription command
    return if @parseLookLocation command

  _availableThings: ->
    _.flatten [@location.things.values(), @options.adventure.inventory.values()]
