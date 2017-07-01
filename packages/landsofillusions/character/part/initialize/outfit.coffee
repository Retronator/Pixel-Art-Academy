LOI = LandsOfIllusions

_.extend LOI.Character.Part.Types,
  Outfit: new LOI.Character.Part
    type: 'Outfit'
    name: 'outfit'
    properties:
      articles: new LOI.Character.Part.Property.Array
        name: 'articles'
        type: 'OutfitArticle'

  OutfitArticle: new LOI.Character.Part.CustomColors
    type: 'OutfitArticle'
    name: 'article'
    properties:
      parts: new LOI.Character.Part.Property.Array
        name: 'parts'
        type: 'OutfitArticlePart'
      customColors: new LOI.Character.Part.Property.Array
        name: 'custom colors'
        type: 'CustomColor'

  OutfitArticlePart: new LOI.Character.Part.Shape
    type: 'OutfitArticlePart'
    name: 'article part'
    renderer: new LOI.Character.Part.Renderers.MappedShape

  CustomColor: new LOI.Character.Part
    type: 'CustomColor'
    name: 'custom color'
    properties:
      name: new LOI.Character.Part.Property.String
        name: 'name'
      color: new LOI.Character.Part.Property.Color
        name: 'color'
