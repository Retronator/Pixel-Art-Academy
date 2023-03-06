RA = Retronator.Accounts
LOI = LandsOfIllusions

window.LandsOfIllusions = LOI
window.LOI = LOI

# Create settings.
LOI.settings = new LOI.Settings

Meteor.startup ->
  # Create and update the singleton default palette texture.
  LOI.paletteTexture = new LOI.Engine.Textures.Palette

  Tracker.autorun (computation) ->
    return unless palette = LOI.palette()
    computation.stop()

    LOI.paletteTexture.update palette
