LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Sync extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Sync'

  @fullName: -> "SYnchronization Neural Connector"
  @shortName: -> "SYNC"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the SYnchronization Neural Connector, SYNC for short.
    "

  @initialize()

  onCommand: (commandResponse) ->
    account = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.LookIn], account.avatar]
      priority: 1
      action: =>
        LOI.adventure.menu.account.show()
