###
    SimUrban Scene Object.
    Written by Bryce on 11/22/2016
    Refactored by Bryce on 12 - 18 - 2016.
    
    Purpose: This class organizes all of the structural layers in the game.
        It serves as the root of the scene graph for all rendering.
        and a hub for the communication between game systems.


    - This class has a reference to all of the layers.
    - Each layer has a reference to this scene object.
    - The scene can return lists of game elements such as cars, buildings, roads, etc.
###

class TSAG.E_Scene extends TSAG.E_Super

    constructor: (scene_width, scene_height) ->

        super(new THREE.Scene())

        view = @getVisual()

        # The network layer manages all of the transportation infrastructure elements, such as roads.
        @_network = new TSAG.E_Network()
        view.add(@_network.getVisual()) # FIXME: We will eventually want to rediscretize this guy depending on viewport.

        # The overlay layer is used to draw visual overlays that serve a purely aesthetic purpose.
        @_overlays = new TSAG.E_Overlays(@)
        view.add(@_overlays.getVisual())

        # We start out not knowing the root of the io tree.
        @_io_root = null

    # Here the scene is informed of the root of all of the controllers.
    # It can also extract lots of relevant one's and store them for later.
    setInputRoot: (io_root) ->
        @_io_root = io_root
        @_io_mouse_main = @_io_root.getMouseController()

        # We defer the initialization of the UI until after
        # we have stable pointers to io controllers.
        @_ui = new TSAG.E_UI_Game(@)
        view.add(@_ui.getVisual())

    # FIXME: This needs to move over to somewhere else.
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

    # -- Layer query functions.

    # Returns the overlay layer.
    getOverlays: () ->
        return @_overlays        

    # Returns the current active UI object.
    getUI: () ->
        return @_ui

    # returns the network layer.
    getNetwork: () ->
        return @_network

    # Returns the default generator of mesh factories.
    getMeshFactory: () ->
        return TSAG.style.unit_meshes



    #-----------------------------------------------
    # -- Element querying functions.
    #-----------------------------------------------


    # Returns a list of all buildings.
    getBuildings: () ->
        return @_buildings

    # Returns a list of all roads.
    getRoads: () ->
        return @_roads

    # Broadcast a UI message to the user.
    ui_message: (str, params) ->

        @_ui.message(str, params)
        return

    # Flash the ui message to blue, it will revert back to its proper state in time.
    ui_flash: () ->

        @_ui.flash()
        return



    #-------------------------------------------------
    # -- Input / Output Querying Functions.
    #-------------------------------------------------

    # Returns the root of the mouse controller tree.
    # This may be used to switch the current mouse behavior.
    get_io_mouse: () ->
        return @_io_mouse_main