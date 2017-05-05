###
#
# Global Style objects, including materials for roads, lines, etc.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
###

TSAG.init_style = () ->
    TSAG.style = 
    {

        radius_road_local:     50,
        radius_road_collector: 75,
        radius_road_artery:    100,

        discretization_length: 10,
        road_offset_amount: 10,

        # Thee length a user needs to drag their mouse between inputs for curve construction.
        user_input_min_move: 10,

        # Materials.
        m_default_fill: new THREE.MeshBasicMaterial( {color: 0xdddddd, side: THREE.DoubleSide} ),
        m_default_line: new THREE.LineBasicMaterial( {color: 0x000000, linewidth:5}),

        # Colors.
        c_building_fill:      new THREE.Color(0xaaaaaa),
        c_building_outline:   new THREE.Color(0x000000),

        c_car_fill:           new THREE.Color(0x00aaaa),

        c_road_fill:          new THREE.Color(0x888888),
        c_road_midline:       new THREE.Color(0x514802),
        c_road_outline:       new THREE.Color(0x000000),
        #road_lane_line  = 

        AABB_testing_material: new THREE.LineBasicMaterial({color: 0x0000ff}),
        cursor_circle_radius: 10,
        cursor_circle_z: 1,
        cursor_circle_color: new THREE.Color(0xff0000),

        # Depth Order.
        dz_intersection: 0.01,
        dz_road: 0,

        dz_cars: .02,

        highlight: new THREE.Color(0x0000ff),
        error:     new THREE.Color(0xff0000),
        action:    new THREE.Color(0x72E261),
        c_normal:  new THREE.Color(0xdddddd),
    }

    # Unit Geometries for rendering.
    # This needs to be below the style specifications, because it looks them up in its constructor.
    TSAG.style.unit_meshes = new TSAG.Unit_Meshes();

    # Returns a material that will contain the given texture when loaded.
    ###
    TSAG.style.load_texture = (url) ->
        material = new THREE.MeshBasicMaterial( {
            map: null
         } );

        loader = new THREE.TextureLoader();

        # load the resource
        loader.load(
            url,
            (texture) ->
                # Color map the material to the loaded texture.
                material.map = texture

                texture.wrapS = THREE.RepeatWrapping;
                texture.wrapT = THREE.RepeatWrapping;
                texture.repeat.set( 40, 40);
            ,
            (xhr) ->
                console.log( (xhr.loaded / xhr.total * 100) + '% loaded' )
            ,
            # Function called when download errors
            ( xhr ) ->
                console.log( "The texture at url: " + url + "  was not loaded." )
        )

        return material
    ###

    TSAG.style.loader = new THREE.TextureLoader()

    # dim {x:, y: w:, h:}
    TSAG.style.newSprite = (url, dim) ->
        
        texture = TSAG.style.loader.load(url)
        geom = new THREE.PlaneBufferGeometry( dim.w, dim.h, 32 )
        mat  = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide, map:texture, transparent: true} )
        mesh = new THREE.Mesh( geom, mat )

        mesh.position.x = dim.w/2
        mesh.position.y = dim.h/2

        mesh.rotation.z = Math.PI

        mesh.scale.x = -1

        # We use a container, so the sprite is now aligned with a position at its top left corner on the screen.
        container = new THREE.Object3D()
        container.add(mesh)

        container.position.x = dim.x
        container.position.y = dim.y

        return container


    TSAG.style.fontLoader = new THREE.FontLoader();
    TSAG.style.textMeshQueue = []

    # Asynchronously load the font into the font loader.
    TSAG.style.fontLoader.load('fonts/Raleway_Regular.typeface.json',
                               (font) ->

                                    TSAG.style.font = font

                                    for params in TSAG.style.textMeshQueue
                                        TSAG.style.newText(params)
                               )

    

    # params: {font: (FontLoader), message: String, height:, out:,
    #           fill_color:0xrrggbb, outline_color:0xff}
    # FIXME: Text is assumed to be left aligned, but I may allow for center alignment eventually.
    # It is expected that the user will position the containing object externally,
    # so that the internal text shapes may be replaced.
    # Creates a new object that contins an outline form and a fill form.
    # adds the object to the out: threejs Object, which will be the container.
    # filled objects are created if a fill is provide.
    # outlined objects are created if an outline is provided.
    TSAG.style.newText = (params) ->

        # If the font is not loaded yet,
        # then we put the request in a queue for processing later,
        # once the font has loaded.
        if not TSAG.style.font
            TSAG.style.textMeshQueue.push(params)
            return

        # Compute shared variables once.
        if params.fill_color or params.outline_color
            message = params.message

            # 2 is the level of subdivision for the paths that are created.
            shapes  = TSAG.style.font.generateShapes( message, params.height, 2 )

            geometry = new THREE.ShapeGeometry( shapes )
            geometry.computeBoundingBox()

        if params.fill_color
            TSAG.style.newFillText(params, shapes, geometry)

        if params.outline_color
            TSAG.style.newOutlineText(params, shapes, geometry)

        params.out.position.z = + .1


    TSAG.style.newFillText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        textShape = new THREE.BufferGeometry()
        
        color_fill = params.fill_color

        material_fill = new THREE.LineBasicMaterial( {
            color: color_fill,
            side: THREE.DoubleSide
        } )

        # Perform Translations.
        xMid = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )
        geometry.scale(1, -1, 1)
        tx = 0
        if params.align_center
            tx = xMid
        geometry.translate( tx, params.height, 0)

        # make shape
        textShape.fromGeometry( geometry )
        text = new THREE.Mesh(textShape, material_fill)
        output.add( text )

    TSAG.style.newOutlineText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        color_outline = params.outline_color

        material_outline = new THREE.MeshBasicMaterial( {
            color: color_outline,
            ###
            transparent: true,
            opacity: 1.0,
            FIXME: Specify Opacity settings.
            ###
            side: THREE.DoubleSide
        } )

        # -- Outlines.

        # Make the letters with holes.
        holeShapes = []
        for i in [0...shapes.length] by 1
            shape = shapes[i]
            if shape.holes and shape.holes.length > 0
                for j in [0...shape.holes.length] by 1 #( var j = 0; j < shape.holes.length; j ++ ) {
                    hole = shape.holes[j]
                    holeShapes.push(hole)

        shapes.push.apply( shapes, holeShapes )
        lineText = new THREE.Object3D()
        params.out.position.z = +.1

        
        # translation amount.
        tx = 0
        if params.align_center
            tx = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )

        #lineText.scale.y = -1
        for i in [0...shapes.length] by 1 #( var i = 0; i < shapes.length; i ++ ) {
            shape = shapes[i]
            lineGeometry = shape.createPointsGeometry()
            lineGeometry.scale(1, -1, 1)
            lineGeometry.translate(tx, params.height, 0 )
            lineMesh = new THREE.Line( lineGeometry, material_outline )
            lineText.add( lineMesh )
        
        output.add( lineText )

        return