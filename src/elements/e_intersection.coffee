#
# Sim Urban Road class.
#
# This class represents Road elements.
#

class TSAG.E_Intersection extends TSAG.E_Super

    constructor: (s_vertex, position) ->

        super()

        # Link to the network vertex.
        # TSAG.S_Vertex
        @_vertex = s_vertex

        # THREE.Vector3
        @_position = position


        fill = TSAG.style.unit_meshes.newSquare({color: TSAG.style.c_road_fill})
        fill.position.copy(@_position.clone())

        sx = sy = TSAG.style.road_offset_amount*2

        fill.scale.copy(new THREE.Vector3(sx, sy, 1))

        view = @getVisual()
        view.add(fill)

        view.position.z = TSAG.style.dz_intersection

    # Adds the given TSAG.e_road object to this intersection.
    # returns false if the given point produces illegal road geometry.
    addRoad: (road) ->

        edge = road.getEdge()
        @_vertex.addEdge(edge)

        # FIXME: Returns false if the intersection is malformed. Set some limits on Intersection construction.
        return true

    getVertex: () ->
        return @_vertex