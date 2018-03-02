AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Quill can only exists on the client.
Quill = require 'quill' if Meteor.isClient

class PAA.PixelBoy.Apps.Journal.JournalView.EntryEditor extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.EntryEditor'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
  
  onRendered: ->
    super
    
    @quill = new Quill @$('.quill')[0]
