AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.EmailItemKeys extends AM.Component
  @id: -> 'Retronator.Store.Pages.EmailItemKeys'
  @register @id()
  
  @version: -> '0.0.1'
  
  @title: ->
    "Retronator // Key claim"
  
  @description: ->
    "Claim external store keys for Retronator products."
  
  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
  
  onCreated: ->
    super arguments...
    
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      
    @submitted = new ReactiveField false

  events: ->
    super(arguments...).concat
      'submit .claim-form': @onSubmitClaimForm

  onSubmitClaimForm: (event) ->
    event.preventDefault()

    email = @$('.claim-email').val()
    
    RS.Item.Key.emailKeys email
    @submitted true
