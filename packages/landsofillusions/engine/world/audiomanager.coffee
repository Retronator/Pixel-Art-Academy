AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.AudioManager
  constructor: (@world) ->
    unless @world.options.isolatedAudio
      # Subscribe to audio assets based on location.
      @world.autorun =>
        return unless locationId = LOI.adventure?.currentLocationId()
        LOI.Assets.Audio.forLocation.subscribe @world, locationId
  
      # Create engine audio assets.
      @engineAudioAssets = {}
  
      @engineAudioDictionary = new AE.ReactiveDictionary =>
        return {} unless locationId = LOI.adventure.currentLocationId()

        audioAssets = {}
        audioAssets[audioAsset._id] = audioAsset for audioAsset in LOI.Assets.Audio.forLocation.query(locationId).fetch()
        audioAssets
      ,
        added: (audioId, audioData) =>
          @engineAudioAssets[audioId] = new LOI.Assets.Engine.Audio
            world: @world
            audioData: new ReactiveField audioData
  
        updated: (audioId, audioData) =>
          @engineAudioAssets[audioId].options.audioData audioData
  
        removed: (audioId, audio) =>
          @engineAudioAssets[audioId].destroy()
          delete @engineAudioAssets[audioId]
