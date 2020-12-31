LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.ShoppingCart.Character extends HQ.Items.ShoppingCart
  onCreated: ->
    super arguments...

    # Items in the character's cart are Things with their IDs as catalog keys.
    @_thingAvatars = []
    @cartItems = new ComputedField =>
      # Destroy previous avatars.
      avatar.destroy() for avatar in @_thingAvatars
      @_thingAvatars = []

      cartItems = []

      for cartItem, index in @contents()
        # Skip any non-existing items (maybe they left from a previous state).
        itemClass = LOI.Adventure.Thing.getClassForId cartItem.item
        continue unless itemClass

        # Create the item's avatar to provide name and description translations.
        avatar = itemClass.createAvatar()
        @_thingAvatars.push avatar

        cartItems.push
          item:
            name: avatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.fullName
            description: avatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.storeDescription
          isGift: cartItem.isGift
          cartIndex: index

      cartItems
