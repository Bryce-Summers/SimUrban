###
    SimUrban Scene Object.
    Written by Bryce on 11/22/2016
    Refactored by Bryce on 12 - 18 - 2016.
    
    Purpose: This class organizes all of the structural layers in the game.
        It serves as the root of the scene graph for all rendering.
###

class TSAG.E_Scene extends TSAG.E_Super

    constructor: (scene_width, scene_height) ->

        super(new THREE.Scene())

        view = @getVisual()

        # The network layer manages all of the transportation infrastructure elements, such as roads.
        @_network = new TSAG.E_Network()
        view.add(@_network.getVisual()) # FIXME: We will eventually want to rediscretize this guy depending on viewport.

        # The overlay layer is used to draw visual overlays that serve a purely aesthetic purpose.
        @_overlays = new THREE.Object3D()
        @_overlays.name = "Overlays"
        view.add(@_overlays)

        @initializeMessageText()

    initializeMessageText: () ->
        text2 = document.createElement('div')
        text2.style.position = 'absolute'
        text2.style.zIndex = 1; # if you still don't see the label, try uncommenting this.
        text2.style.width  = 100
        text2.style.height = 100
        text2.style.backgroundColor = "blue"
        text2.innerHTML = "[Blank]"
        text2.style.top = 0 + 'px'
        text2.style.left = 0 + 'px'
        document.body.appendChild(text2)
        @message_text = text2

    constructRandomBuildings: () ->

        # FIXME: Buildings should be factored into the network.
        @_building_visuals = new THREE.Object3D()
        @_building_visuals.name = "Building Visuals"
        view.add(@_building_visuals)

        @_buildings = []
        
        @_scale   = 40
        @_padding = 30

        # Construct a bunch of buildings.
        for i in [0...10]
            x = @_padding + Math.random() * (scene_width  - @_padding * 2)
            y = @_padding + Math.random() * (scene_height - @_padding * 2)
            w = @_scale
            h = @_scale
            
            # Z rotation in the plane.
            rz = Math.random() * Math.PI*2

            pos   = new THREE.Vector3(x, y, 0)
            scale = new THREE.Vector3(w, h, 1)

            building = new TSAG.E_Building(pos, scale, rz)
            @_buildings.push(building)
            @_building_visuals.add(building.getVisual())

        return

    # Adds the given THREE.Object3 to the overlay layer.
    addOverlayVisual: (obj) ->
        @_overlays.add(obj)

    removeOverlayVisual: (obj) ->
        @_overlays.remove(obj)

    getNetwork: () ->
        return @_network

    getMeshFactory: () ->
        return TSAG.style.unit_meshes

    getNetwork: () ->
        return @_network

    # Returns a list of all buildings.
    getBuildings: () ->
        return @_buildings

    getRoads: () ->
        return @_roads

    # Broadcast a UI message to the user.
    # params: {type:, element:}
    # type: {'info':, 'error'}
    # element: contains an element that may be colored to reflect this message.
    ui_message: (str, params) ->
        
        if params.type == 'info'
            @message_text.style.backgroundColor = "blue"

            if params.element
                params.element.revertFillColor()

        else if params.type == 'error'
            @message_text.style.backgroundColor = "red"

            if params.element
                params.element.setFillColor(TSAG.style.error)

        @message_text.innerHTML = str

        return

