LOI = LandsOfIllusions

class Retropolis

if Meteor.isServer
  # Export assets in the retropolis folder.
  LOI.Assets.addToExport 'retropolis'

if Meteor.isClient
  # Create a global variable for debugging purposes.
  window.Retropolis = Retropolis
