AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Test extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Test'

  constructor: (@terminal) ->

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
