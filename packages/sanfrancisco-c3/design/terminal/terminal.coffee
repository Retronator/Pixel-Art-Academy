AM = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Design.Terminal extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.C3.Design.Terminal'
  @url: -> 'c3/design-control/terminal'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "design terminal"
  @shortName: -> "terminal"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's the computer where you can design your character.
    "

  @initialize()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  onCreated: ->
    super
    
    @bodyNode = new ComputedField =>
      return unless character = LOI.character()
      return unless character.avatarData.body
  
      # Create the body hierarchy.
      AM.Hierarchy.create character.avatarData.body

    @descriptionTranslations = new ComputedField =>
      return unless bodyNode = @bodyNode()
    
      # Find all nodes that hold a description.
      nodesWithDescription = bodyNode.childNodesWith (node) => node.description
    
      for node in nodesWithDescription
        node.description()
  
    @portraitNodes = new ComputedField =>
      return unless bodyNode = @bodyNode()

      # Get the head node.
      headNode = bodyNode.head()

      # Find all nodes that hold a sprite.
      headNode.childNodesWith (node) => node.spriteId
    
    # Subscribe to all sprites of the portrait.
    @autorun (computation) =>
      return unless portraitNodes = @portraitNodes()

      for portraitNode in portraitNodes
        spriteId = portraitNode.spriteId()

        LOI.Assets.Sprite.forId.subscribe spriteId

    @portraitSprites = new ComputedField =>
      return unless portraitNodes = @portraitNodes()

      spriteIds = for portraitNode in portraitNodes
        portraitNode.spriteId()

      LOI.Assets.Sprite.documents.find _id: $in: spriteIds
