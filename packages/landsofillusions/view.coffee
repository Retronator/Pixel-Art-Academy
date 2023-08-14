AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
FM = FataMorgana

class LOI.View extends FM.View
  constructor: ->
    super arguments...
    
    @audioMixin = new LOI.Components.Mixins.Audio @
    
  mixins: -> super(arguments...).concat @audioMixin
