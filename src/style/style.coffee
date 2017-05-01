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
        m_default_fill: new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide} ),
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
    TSAG.style.font = TSAG.style.fontLoader.load('fonts/Raleway_Regular.typeface.json')

    # parames: {font: (FontLoader), message: String, x:, y:, height:}
    TSAG.style.newText = (params) ->

                    ###
                    var xMid, text;
                    var textShape = new THREE.BufferGeometry();
                    var color = 0x006699;
                    var matDark = new THREE.LineBasicMaterial( {
                        color: color,
                        side: THREE.DoubleSide
                    } );
                    var matLite = new THREE.MeshBasicMaterial( {
                        color: color,
                        transparent: true,
                        opacity: 0.4,
                        side: THREE.DoubleSide
                    } );
                    var message = "   Three.js\nSimple text.";
                    var shapes = font.generateShapes( message, 100, 2 );
                    var geometry = new THREE.ShapeGeometry( shapes );
                    geometry.computeBoundingBox();
                    xMid = - 0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x );
                    geometry.translate( xMid, 0, 0 );
                    // make shape ( N.B. edge view not visible )
                    textShape.fromGeometry( geometry );
                    text = new THREE.Mesh( textShape, matLite );
                    text.position.z = - 150;
                    scene.add( text );
                    // make line shape ( N.B. edge view remains visible )
                        var holeShapes = [];
                    for ( var i = 0; i < shapes.length; i ++ ) {
                        var shape = shapes[ i ];
                        if ( shape.holes && shape.holes.length > 0 ) {
                            for ( var j = 0; j < shape.holes.length; j ++ ) {
                                var hole = shape.holes[ j ];
                                holeShapes.push( hole );
                            }
                        }
                    }
                    shapes.push.apply( shapes, holeShapes );
                    var lineText = new THREE.Object3D();
                    for ( var i = 0; i < shapes.length; i ++ ) {
                        var shape = shapes[ i ];
                        var lineGeometry = shape.createPointsGeometry();
                        lineGeometry.translate( xMid, 0, 0 );
                        var lineMesh = new THREE.Line( lineGeometry, matDark );
                        lineText.add( lineMesh );
                    }
                    scene.add( lineText );
                } ); //end load function
                ###