AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Journal.JournalsView.SceneManager
  constructor: (@journalsView) ->
    @scene = new AE.ReactiveWrapper null

    # Initialize components.
    scene = new THREE.Scene()
    @scene scene

    # Instantiate journal meshes.
    @_journalMeshesById = {}
    @journalMeshesById = new ReactiveField @_journalMeshesById

    addJournalMesh = (journal) =>
      journalMesh = new PAA.PixelPad.Apps.Journal.JournalsView.JournalMesh @, journal
      scene.add journalMesh
      @_journalMeshesById[journal._id] = journalMesh

      @journalMeshesById @_journalMeshesById

    removeJournalMesh = (journal, skipReactiveUpdate) =>
      journalMesh = @_journalMeshesById[journal._id]
      scene.remove journalMesh
      journalMesh.destroy()
      delete @_journalMeshesById[journal._id]

      @journalMeshesById @_journalMeshesById unless skipReactiveUpdate

    PAA.Practice.Journal.documents.find(
      'character._id': LOI.characterId()
    ).observe
      added: (document) =>
        addJournalMesh document

      changed: (newDocument, oldDocument) =>
        removeJournalMesh oldDocument, true
        addJournalMesh newDocument

      removed: (oldDocument) =>
        removeJournalMesh oldDocument

    # Reposition meshes in order.
    @journalsView.autorun (computation) =>
      journalMeshes = _.values @journalMeshesById()
      journalMeshes = _.sortBy journalMeshes, 'journal.order'

      for journalMesh, index in journalMeshes
        journalMesh.position.x = index * 50
        journalMesh.updateMatrixWorld()

      @scene.updated()

    # Create scene lighting
    directionalLight = new THREE.DirectionalLight 0xffffdd, 0.8
    directionalLight.position.set -130, 80, -100
    directionalLight.castShadow = true
    d = 100
    directionalLight.shadow.camera.left = -d
    directionalLight.shadow.camera.right = d
    directionalLight.shadow.camera.top = d
    directionalLight.shadow.camera.bottom = -d
    directionalLight.shadow.camera.near = 50
    directionalLight.shadow.camera.far = 500
    directionalLight.shadow.mapSize.width = 4096
    directionalLight.shadow.mapSize.height = 4096
    directionalLight.shadow.bias = 0.0001
    scene.add directionalLight

    scene.add new THREE.HemisphereLight 0xbbddee, 0x6688dd, 0.8

    # Create other scene meshes.
    plane = new THREE.Mesh new THREE.PlaneBufferGeometry(10000, 10000, 1, 1), new THREE.MeshPhongMaterial color: 0x666666
    plane.position.set 0, 0, -4900
    plane.rotation.x = -Math.PI / 2
    plane.receiveShadow = true
    scene.add plane

  destroy: ->
    journalMesh.destroy() for id, journalMesh of @_journalMeshesById

  getJournalMeshForId: (journalId) ->
    @journalMeshesById()[journalId]
