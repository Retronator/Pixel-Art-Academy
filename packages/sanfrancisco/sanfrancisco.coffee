LOI = LandsOfIllusions

class SanFrancisco

if Meteor.isServer
  # Export assets in the sanfrancisco folder.
  LOI.Assets.addToExport 'sanfrancisco'

if Meteor.isClient
  # Create a global variable for debugging purposes.
  window.SanFrancisco = SanFrancisco
