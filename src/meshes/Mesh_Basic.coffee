###
    Super class to mesh construction classes.

    Written by Bryce Summers on 11/22/2016.
    
    Purpose:
        Deals with all of the common problems such as adding a material and changing its color.
###

class TSAG.Mesh_Basic extends THREE.Mesh

    constructor: (area_geometry, @outline_geometry) ->

        # Affix the geometry with a material.
        material = new THREE.MeshBasicMaterial( {color: 0xaaaaaa, side: THREE.DoubleSide} );
        super(area_geometry, material);

        
        # Black Line color.
        @line_material = new THREE.LineBasicMaterial({
            color: 0x000000, linewidth:5
        });
        #@line = new THREE.LineSegments( @outline_geometry, @line_material );

        # FIXME: THREE.js bug? HACKED to false.
        # Evidently lines have problems computing their bounding spheres.
        #@add( line );
        
    # color: fill color.
    clone: (params) ->
        output  = new THREE.Object3D()
        mesh    = new TSAG.Mesh_Basic(@geometry)
        outline = new THREE.Line(@outline_geometry, @line_material)
        outline.renderOrder = 1
        output.add(mesh)
        output.add(outline)

        # Act on params.
        mesh.material.color = new THREE.Color(params.color);

        return output;