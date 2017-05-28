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

    @headEyes = new ComputedField =>
      LOI.character()?.avatar.body('head')? 'numberOfEyes'

    Meteor.setInterval =>
      LOI.character()?.avatar.body('head')? 'numberOfEyes', _.random 10
    ,
      5000

    @descriptionTranslations = new ComputedField =>
      return unless bodyNode = LOI.character()?.avatar.body

      return

      # Find all nodes that hold a description.
      nodesWithDescription = bodyNode.childNodesWith (node) => node.description
    
      for node in nodesWithDescription
        node.description()
  
    @portraitNodes = new ComputedField =>
      return unless bodyNode = LOI.character()?.avatar.body

      # Get the head node.
      headNode = bodyNode 'head'

      return

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
