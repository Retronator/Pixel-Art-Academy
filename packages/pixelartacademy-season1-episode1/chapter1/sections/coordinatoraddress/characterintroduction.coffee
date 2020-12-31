LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Nodes = LOI.Adventure.Script.Nodes
Vocabulary = LOI.Parser.Vocabulary

class C1.CoordinatorAddress.CharacterIntroduction extends LOI.Memory.Action
  # content:
  #   introduction: the message said by the character to introduce themselves
  @type: 'PixelArtAcademy.Season1.Episode1.Chapter1.CoordinatorAddress.CharacterIntroduction'
  @register @type, @

  @registerContentPattern @type,
    introduction: String

  @isMemorable: -> true
    
  # Subscriptions
  
  @latestIntroductionForCharacter: @subscription 'latestIntroductionForCharacter',
    query: (characterId) =>
      LOI.Memory.Action.documents.find
        type: C1.CoordinatorAddress.CharacterIntroduction.type
        'character._id': characterId
      ,
        order:
          time: -1
        limit: 1

  @all: @subscription 'all'
