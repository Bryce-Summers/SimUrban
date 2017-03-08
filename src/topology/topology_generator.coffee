###
Sim Urban Topology Linked Element Generator.

Written by Bryce Summers on 3 - 7 - 2017.

Purpose
###

###

Polyline Graph Topology Generator.

Generates Halfedge Topology associated with Polyline Graph Data Objects.

Written by Bryce Summers
Move to its own file on 3 - 7 - 2017.
###
class TSAG.PolylineGraphGenerator

    constructor: (@_graph) ->

        # New Element storages.
        new_faces     = []
        new_edges     = []
        new_halfedges = []
        new_vertices  = []

    # Allocates a new graph, stores it in this graph generator and returns it.
    allocateGraph: () ->
        @_graph = @newGraph()
        return @_graph

    # These functions should be used in all of my processings of polyline graphs.
    newGraph: () ->
        output       = new SCRIB.Graph(false) # Don't allocate index arrays.
        output.data  = new TSAG.Graph_Data(output)
        return output

    newFace: (graph) ->
        graph = @_graph if not graph
        output  = graph.newFace()
        output.data = new TSAG.Face_Data(output)
        @new_faces.push(output)
        return output

    newEdge: (graph) ->
        graph = @_graph if not graph
        output      = graph.newEdge()
        output.data = new TSAG.Edge_Data(output)
        @new_edges.push(output)
        return output

    newHalfedge: (graph) ->
        graph = @_graph if not graph
        output      = graph.newHalfedge()
        output.data = new TSAG.Halfedge_Data(output)
        @new_halfedges.push(output)
        return output

    newVertex: (graph) ->
        graph = @_graph if not graph
        output = graph.newVertex()
        output.data  = new TSAG.Vertex_Data(output)
        @new_vertices.push(output)
        return output

    # External functions can retrieve lists of newly allocated elements from here 
    # and process then in a application specific manner.
    # For instance, A road building tool can associate verts with intersections, and edges with roads, etc.
    flushNewFaces: () ->
        output = @new_faces
        @new_faces = []
        return output

    flushNewEdges: () ->
        output = @new_edges
        @new_edges = []
        return output

    flushNewHalfedges: () ->
        output = @new_halfedges
        @new_halfedges = []
        return output

    flushNewVertices: () ->
        output = @new_vertices
        @new_vertices = []
        return output


    ######################################################################
    #
    # Functions required to fullfill the generator interface for use with
    # SCRIB.TopologyLinker.
    #
    ######################################################################

    # According to the ray vert1 --> vert2,
    # returns which side vert3 is on.
    # This is necessary for planar topological updates, such as splitting faces.
    # This is a useful geometric condition that has ties to orientation.
    line_side_test: (vert1, vert2, vert3) ->
        
        pt_c = vert3.data.point
        ray = @_ray(vert1, vert2)

        return ray.line_side_test(pt_c)

    # Returns true if vert_pt is inside of the angle ABC, where a, b, c are vertices.
    # This will be used for linking edges to the correct angle.
    # pt is inside if it is counterclockwise to BA and clockwise to BC.
    # SCRIB.Vertex, Vertex, Vertex, Vertex.
    vert_in_angle: (vert_a, vert_b, vert_c, vert_pt) ->

        # Due to the orientation of a Computer Graphics plane,
        # we have swapped vert a and vert c.
        ray1 = @_ray(vert_b, vert_c)
        ray2 = @_ray(vert_b, vert_a)

        ray_pt = @_ray(vert_b, vert_pt)
 
        angle1 = ray1.getAngle()
        angle2 = ray2.getAngle()
        angle_pt = ray_pt.getAngle()

        # Apply mod Math.PI*2 wrapping functions to ensure the integrity of the check.
        # Make sure angle2 is an upper bound.
        if angle2 <= angle1 # NOTE: Equality enables correct tail angles that encompass the entire 360 degrees.
            angle2 += Math.PI*2

        if angle_pt < angle1
            angle_pt += Math.PI*2

        # Return if in bounds.
        return angle1 <= angle_pt and angle_pt <= angle2

    _ray: (v1, v2) ->
        a = v1.data.point
        b = v2.data.point

        dir = b.sub(a)

        ray = new BDS.Ray(a, dir, 1)
        return ray