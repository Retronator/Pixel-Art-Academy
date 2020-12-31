LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.StillLifeStand extends PAA.StillLifeStand
  @id: -> 'Retronator.HQ.ArtStudio.StillLifeStand'
  @url: -> 'retronator/artstudio/stilllife'

  @fullName: -> "still life stand"
  @shortName: -> "stand"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "Still life ![stand](use stand)."
  @description: ->
    "
      A stand is placed in the middle of the studio with various items on display.
      Artists use this as a reference to study lighting and practice drawing and painting technique.
    "

  @startingItems: ->
    JSON.parse '[{"type":"PixelArtAcademy.Items.StillLifeItems.Bowl.Large.High","id":"PNHhGqq3LZwYTMZja","position":{"x":-0.011535877361893654,"y":0.05999330058693886,"z":0.014963936991989613},"rotationQuaternion":{"x":-0.0000075181046668149065,"y":-0.7871829867362976,"z":-0.0000037807189983141143,"w":0.6167194843292236}},{"type":"PixelArtAcademy.Items.StillLifeItems.Apple.Green","id":"RxLYWLpemBgLAzrdn","position":{"x":-0.03248648717999458,"y":0.09383872896432877,"z":-0.01960756443440914},"rotationQuaternion":{"x":-0.07664971798658371,"y":-0.4677290916442871,"z":0.794111967086792,"w":0.38044774532318115}},{"type":"PixelArtAcademy.Items.StillLifeItems.Apple.Green","id":"tTTHgxyBpT24hpH3t","position":{"x":0.001081727328710258,"y":0.23933885991573334,"z":0.039703089743852615},"rotationQuaternion":{"x":0.7820539474487305,"y":0.008347864262759686,"z":0.3120157718658447,"w":0.5394145846366882}},{"type":"PixelArtAcademy.Items.StillLifeItems.Apple.Green","id":"MkMoQT5bfQygfeeEe","position":{"x":0.02426340989768505,"y":0.12625116109848022,"z":0.0752202644944191},"rotationQuaternion":{"x":0.4601672291755676,"y":0.3457673192024231,"z":-0.6154776811599731,"w":0.5384034514427185}},{"type":"PixelArtAcademy.Items.StillLifeItems.Orange","id":"vTHeR7T3AM9s6XNNT","position":{"x":0.05355226993560791,"y":0.16561183333396912,"z":-0.028673039749264717},"rotationQuaternion":{"x":-0.04242425039410591,"y":0.9093060493469238,"z":-0.33891555666923523,"w":-0.23769515752792358}},{"type":"PixelArtAcademy.Items.StillLifeItems.Orange","id":"QS72adncLnSBBF355","position":{"x":-0.07980859279632568,"y":0.16261379420757294,"z":0.05662404000759125},"rotationQuaternion":{"x":-0.49723026156425476,"y":0.172637477517128,"z":0.8439733982086182,"w":-0.10328225791454315}},{"type":"PixelArtAcademy.Items.StillLifeItems.Mango","id":"qgTvsTC9SWSFNZjmK","position":{"x":-0.0572640597820282,"y":0.20269238948822021,"z":-0.05663297697901726},"rotationQuaternion":{"x":0.48543113470077515,"y":0.7881830334663391,"z":-0.3731296956539154,"w":0.06243632733821869}}]'

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    stand = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], stand.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem stand
