###
    Sim Urban User Interface Object.
    Written by Bryce on May.4.2017
    
    Purpose: This class provide general functions for the operation of UI's
        - static visual generation.
        - creation and deletion of buttons.

        This class also handles the text based display of information to the users.
###

class TSAG.E_UI extends TSAG.E_Super

    constructor: (@scene) ->

        super()

        # This stores the state of the UI_buttons.
        @_bvh = new BDS.BVH2D([])
        @_elements = new Set()

        # FIXME: Get this from teh UI controller.
        @_c_resting       = new THREE.Color(0xe6dada)
    
    # Create a button displayed at the given area: BDS.Polyline.
    # visually represented by the given material,
    # and which should call the given function when clicked.
    createButton: (area, material, click_function) ->
    
        ###
         * An element is an associative object of the following form:
         * {click:    () -> what happens when the user clicks on this element.
         *  polyline: A polyline representing the collision detection region for the object.
         *  material: a pointer to the material object responsible for filling the actual
         *  object on the screen.
        ###

        # Start the material off in the resting state.
        material.color = @_c_resting

        element =   {click: click_function
                    ,polyline:area
                    ,material: material}

        element.polyline.setAssociatedData(element)
        @_bvh.add(element.polyline)
        @_elements.add(element)

        return element

    # Remove the given button from the elements and bvh structures.
    removeButton: (b) ->
        a = @_elements.delete(b)
        b = @_bvh.remove(b.polyline)

        # Return true if the button was removed from all data structures.
        return a and b

    # Query function used to retrieve the UI element at the given point.
    # Used as the primary interface to UI mouse controllers.
    query_point: (pt) ->
        return @_bvh.query_point(pt)

    ###

    Internal Helper functions.

    ###

    # {fill:, x:, y:, w:, h:, depth}
    # x and y of top left corner.
    _createRectangle: (params) ->
        rect = TSAG.style.unit_meshes.newSquare({color: new THREE.Color(params.fill)})
        rect.scale.x = params.w
        rect.scale.y = params.h
        rect.position.x = params.x + params.w/2
        rect.position.y = params.y + params.h/2
        rect.position.z = params.depth

        return rect



















        ###
        mesh.scale.x = 200
        mesh.scale.y = 200
        

        view.add(mesh)

        window.mesh = mesh
        ###


        # -- Tools Controllers extracted from input tree.
        ###
        @controller_build_road = 
        @controller_build_road.setActive(false)
        @controller_demolish_road = 
        @controller_demolish_road.setActive(false)
        ###


        ###
        # -- Tools UI Buttons.
        b1 = new BDS.Box(new BDS.Point(0,   0),
                         new BDS.Point(64, 64));

        b2 = new BDS.Box(new BDS.Point(64,   0),
                         new BDS.Point(128, 64));

        b3 = new BDS.Box(new BDS.Point(128,  0),
                         new BDS.Point(192, 64));

        p1 = b1.toPolyline()
        p2 = b2.toPolyline()

        # Modification functions.
        func_build_road_local     = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_local
            @controller_build_road.setMode(mode)

        func_build_road_collector = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_collector
            @controller_build_road.setMode(mode)

        func_build_road_artery    = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_artery
            @controller_build_road.setMode(mode)

        img_build_road_local     = null # Load Local road building image.
        img_build_road_collector = null # Load Collector road building image.
        img_build_road_artery    = null # Load Arterial road building image.

        @controller_ui.createButton(p1, func_build_road_local,     img_build_road_local)
        @controller_ui.createButton(p2, func_build_road_collector, img_build_road_collector)
        @controller_ui.createButton(p2, func_build_road_artery,    img_build_road_artery)
        ###