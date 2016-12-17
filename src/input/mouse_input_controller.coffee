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
        mesh = mesh_factory.newCircle(params)


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

        results = @scene.queryPoint(event.x, event.y)
        console.log(event.x, event.y)
        if results != null
            mesh         = results[0]
            intersection = results[1]
            mesh.material.color.set( 0xff0000 )


        # FIXME: Remove this after query testing is done.
        return

        # We won't be using the right button for anything.
        return if rightButton

        if @state == "idle"
        
            # Create the spline.
            @road = new TSAG.Curve();
            @road.addPoint(new THREE.Vector3( event.x, event.y, 0))
            # The second point is used as the dummy point during mouse movements.
            @road.addPoint(new THREE.Vector3( event.x, event.y+1, 0))
            
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

                # Round last point.
                pos = @road.getLastPoint()
                pos.x = Math.floor(pos.x)
                pos.y = Math.floor(pos.y)

                # We use offsets to prevent 0 length splines that cause degenerate behavior.
                @road.addPoint(new THREE.Vector3( event.x + .01, event.y + .01, 0))

                @_mousePrevious.x = event.x
                @_mousePrevious.y = event.y
            # Stop the interaction if the user is sufficiently close to their
            # previous tap.
            else

                # Round last point.
                @road.removeLastPoint()

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

        pos.x = event.x
        pos.y = event.y


        # FIXME: Clean this up.
        if @road_obj
            @scene.remove(@road_obj)

        if @state == "building"
            len = @road.numPoints()
            pos = @road.getPointAtIndex(len - 1)

            # We use random numbers to ensure a lack of degeneracy.
            pos.x = event.x + .01
            pos.y = event.y + .01

            max_length     = 10;
            offset_amount = 10;
            @road.updateDiscretization(10)

            # -- Compute various lines for the road.
            # We will pack them into a single THREE.js Object.
            @road_obj = new THREE.Object3D()

            # For now, we will use simple black strokes.
            material = new THREE.LineBasicMaterial( { color : 0x000000 } )
            middle_material = new THREE.LineBasicMaterial( { color : 0x514802 } )

            middle_line = new THREE.Geometry()
            middle_line.vertices = @road.getDiscretization()
            @road_obj.add(new THREE.Line( middle_line, middle_material ))

            left_line = new THREE.Geometry()
            left_line.vertices = @road.getOffsets(max_length, offset_amount)
            @road_obj.add(new THREE.Line( left_line, material ))

            right_line = new THREE.Geometry()
            right_line.vertices = @road.getOffsets(max_length, -offset_amount)
            @road_obj.add(new THREE.Line( right_line, material ))

            # Create the final Object3d to add to the scene
            @scene.add(@road_obj)