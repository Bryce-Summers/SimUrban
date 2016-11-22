###
    Square Mesh.

    Initializes as a unit square at the origin.

    Written by Bryce Summers on 11/22/2016.
    
    Purpose:
     - Provides a unit square that can then be scaled, positioned, and rotated.
###

class TSAG.Mesh_Unit_Square extends TSAG.Mesh_Basic

    constructor: () ->

        # Creat a plane that is perpendicular facing to the z axis.
        geometry = new THREE.PlaneBufferGeometry( 1, 1);

        
        outline = new THREE.Geometry();
        outline.vertices.push(
            new THREE.Vector3( -.5, -.5, 0 ),
            new THREE.Vector3(  .5, -.5, 0 ),
            new THREE.Vector3(  .5,  .5, 0 ),
            new THREE.Vector3( -.5,  .5, 0 ),
            new THREE.Vector3( -.5, -.5, 0 ) # Closed.
        );

        super(geometry, outline)