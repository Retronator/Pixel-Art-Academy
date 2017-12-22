LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Audio extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Audio'

  @fullName: -> "cassette tape"

  @initialize()

  descriptiveName: ->
    "A ![cassette tape](listen to cassette tape)."

  description: ->
    "It's one of those old audio storage mediums."

  _createIntroScript: ->
    # Create the iframe embed.
    $audio = $(@post.audio.player)
    $audio.addClass('retronator-hq-store-table-item-audio')

    # We inject the html of the player.
    audioNode = new Nodes.NarrativeLine
      line: "%%html#{$audio[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # User listens to the audio in this post.
    new Nodes.NarrativeLine
      line: "You press play on the cassette recorder and listen to the tape:"
      next: audioNode

  onCommand: (commandResponse) ->
    super

    audio = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.ListenTo, Vocabulary.Keys.Verbs.Use], audio.avatar]
      action: => audio.start()
