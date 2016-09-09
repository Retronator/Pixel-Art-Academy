LOI = LandsOfIllusions
Actor = LOI.Adventure.Actor

class Actor.Abilities.Action extends Actor.Ability
  @register 'LandsOfIllusions.Adventure.Actor.Abilities.Action'

  constructor: (options) ->
    super

    @verb = options.verb
    @action = options.action

  events: ->
    super.concat
      'click .action-button': @onClickActionButton
      'mouseover .action-button': @onMouseoverActionButton
      'mouseout .action-button': @onMouseoutActionButton

  onClickActionButton: (event) ->
    # Perform the action.
    @action()

  onMouseoverActionButton: (event) ->
    # ideally, this would be a reactive field, but unsure of ability to change contexts
    # .console-log exists in location
    $('.console-log').html(@verb)

  onMouseoutActionButton: (event) ->
    $('.console-log').empty()
