LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Answer extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Answer'

  # HACK: We refer to this item as both a question and an answer, but use question as the full name,
  # so that it appears when the system asked you to pick one of the questions to interact with.
  @fullName: -> "question"
  @shortName: -> "answer"

  @initialize()

  descriptiveName: ->
    "A ![question](see the answer)."

  description: ->
    "A question someone asked Retro."

  _createIntroScript: ->
    # Create the answer html.
    $answer = $('<div class="retronator-hq-store-table-item-answer">')
    $answer.append("<div class='question'>#{@post.question.question}</div>")

    $asker = $("<p class='asker'>&mdash;</p>")

    if @post.question.askingUrl
      $asker.append "<a href='#{@post.question.askingUrl}' target='_blank'>#{@post.question.askingName}</a>"

    else
      $asker.append "#{@post.question.askingName}"

    $answer.append $asker

    # We inject the html of the answer.
    answerNode = new Nodes.NarrativeLine
      line: "%%html#{$answer[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # User looks at the message.
    new Nodes.NarrativeLine
      line: "You see a message:"
      next: answerNode
      
  onCommand: (commandResponse) ->
    super arguments...

    answer = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.ListenTo, Vocabulary.Keys.Verbs.Read], answer.avatar]
      action: => answer.start()
