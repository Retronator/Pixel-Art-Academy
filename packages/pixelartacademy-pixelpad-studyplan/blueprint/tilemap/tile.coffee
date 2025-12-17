import {ReactiveField} from "meteor/peerlibrary:reactive-field"

AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.TileMap.Tile
  constructor:  ->
    @buildingActive = new ReactiveField false
    @gateOpened = new ReactiveField false
    @flagRaised = new ReactiveField false
    @revealed = new ReactiveField false
  
  resetWithData: (@data) ->
    @buildingActive false
    @gateOpened false
    @flagRaised false
    @revealed false
