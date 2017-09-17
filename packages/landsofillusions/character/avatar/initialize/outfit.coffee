LOI = LandsOfIllusions

LOI.Character.Part.registerClasses
  Avatar:
    Outfit: new LOI.Character.Part
      type: 'Avatar.Outfit'
      name: 'outfit'
      properties:
        articles: new LOI.Character.Part.Property.Array
          name: 'articles'
          type: 'Avatar.Outfit.Article'

LOI.Character.Part.registerClasses
  Avatar:
    Outfit:
      Article: new LOI.Character.Avatar.Parts.CustomColors
        type: 'Avatar.Outfit.Article'
        name: 'article'
        properties:
          parts: new LOI.Character.Part.Property.Array
            name: 'parts'
            type: 'Avatar.Outfit.ArticlePart'
          customColors: new LOI.Character.Part.Property.Array
            name: 'custom colors'
            type: 'Avatar.Outfit.CustomColor'

      ArticlePart: new LOI.Character.Avatar.Parts.Shape
        type: 'Avatar.Outfit.ArticlePart'
        name: 'article part'
        renderer: new LOI.Character.Avatar.Renderers.MappedShape

      CustomColor: new LOI.Character.Part
        type: 'Avatar.Outfit.CustomColor'
        name: 'custom color'
        properties:
          name: new LOI.Character.Part.Property.String
            name: 'name'
          color: new LOI.Character.Avatar.Properties.Color
            name: 'color'
