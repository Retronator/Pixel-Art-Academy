LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Account extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Account'

  @fullName: -> "account folder"
  @shortName: -> "account"

  @description: ->
    "
      It holds all the documents with details about your account at Retronator.
    "

  @initialize()

  onCommand: (commandResponse) ->
    button = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.LookIn], button.avatar]
      priority: 1
      action: =>
        LOI.adventure.menu.account.show()
