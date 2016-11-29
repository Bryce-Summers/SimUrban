#
# Mouse Input Manager
#
# Written by Bryce Summers on 11/22/2016
#

class TSAG.Mouse_Input_Controller

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        mesh_factory = @scene.getMeshFactory()

        params = {color: 0xff0000}

        # THREE.js Mesh
        mesh = mesh_factory.newCircle(params);


        # fixme: Put this in a style guide class.
        scale = 10
        mesh.position.z = 1

        w = scale
        h = scale

        scale = mesh.scale
        scale.x = w
        scale.y = h

        @scene.add(mesh);

        @pointer = mesh

        @state = "idle";

        @_mousePrevious = {x:0, y:0}

        @_min_dist = 10

    mouse_down: (event, rightButton) ->

        if @state == "idle"
        
            # Create the spline.
            @road = new THREE.CatmullRomCurve3( [
                new THREE.Vector3( event.x, event.y, 0),
                new THREE.Vector3( event.x, event.y, 0)
            ] );

            @state = "building"
            @_mousePrevious.x = event.x
            @_mousePrevious.y = event.y

        else

            dist = TSAG.Math.distance(
                        event.x, event.y,
                        @_mousePrevious.x,
                        @_mousePrevious.y)

            # Build more road if the user clicks far enough away.
            if dist > @_min_dist
                @road.points.push(new THREE.Vector3( event.x, event.y, 0));

                @_mousePrevious.x = event.x
                @_mousePrevious.y = event.y
            # Stop the interaction if the user is sufficiently close to their
            # previous tap.
            else
                @state = "idle"
                # Preserve the road object.
                @road_obj = null    
            

        # We are removing all dependance on right clicking.
        ###
        if rightButton
            @state = "idle"
            # Preserve the Road object.
            @road_obj = null
        ###

    mouse_up:   (event) ->

    mouse_move: (event) ->
        pos = @pointer.position;

        screen_w = window.innerWidth;
        screen_h = window.innerHeight;

        pos.x = event.x;
        pos.y = event.y;


        # FIXME: Clean this up.
        if @road_obj
            @scene.remove(@road_obj)

        if @state == "building"
            len = @road.points.length
            pos = @road.points[len - 1]
            pos.x = event.x
            pos.y = event.y

            geometry = new THREE.Geometry();
            geometry.vertices = @road.getPoints( 500 );

            material = new THREE.LineBasicMaterial( { color : 0x000000 } );

            #Create the final Object3d to add to the scene
            @road_obj = new THREE.Line( geometry, material );
            @scene.add(@road_obj)