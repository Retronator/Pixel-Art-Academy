LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Nodes = LOI.Adventure.Script.Nodes
Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.IceBreakers.AnswerAction extends LOI.Memory.Action
  # content:
  #   question: ID of the question
  #   answer: integer representing the side the character chose 
  @type: 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.IceBreakers.AnswerAction'
  @register @type, @

  @registerContentPattern @type,
    question: String
    answer: Match.IntegerRange 0, 2

  @isMemorable: -> true
    
  @translations: ->
    0: "_person_ is on the left side of the room."
    1: "_person_ is in the middle of the room."
    2: "_person_ is on the right side of the room."
   
  # Subscriptions
  
  @latestAnswersForCharacter: @subscription 'latestAnswersForCharacter'

  activeDescription: ->
    @translations()?[@content.answer]
