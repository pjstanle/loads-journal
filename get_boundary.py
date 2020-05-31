import numpy as np
from scipy.spatial import ConvexHull
import sys
sys.dont_write_bytecode = True

def calculate_boundary(vertices):

    # find the points that actually comprise a convex hull
    hull = ConvexHull(list(vertices))

    # keep only vertices that actually comprise a convex hull and arrange in CCW order
    vertices = vertices[hull.vertices]

    # get the real number of vertices
    nVertices = vertices.shape[0]

    # initialize normals array
    unit_normals = np.zeros([nVertices, 2])

    # determine if point is inside or outside of each face, and distance from each face
    for j in range(0, nVertices):

        # calculate the unit normal vector of the current face (taking points CCW)
        if j < nVertices - 1:  # all but the set of point that close the shape
            normal = np.array([vertices[j+1, 1]-vertices[j, 1],
                               -(vertices[j+1, 0]-vertices[j, 0])])
            unit_normals[j] = normal/np.linalg.norm(normal)
        else:   # the set of points that close the shape
            normal = np.array([vertices[0, 1]-vertices[j, 1],
                               -(vertices[0, 0]-vertices[j, 0])])
            unit_normals[j] = normal/np.linalg.norm(normal)

    return vertices, unit_normals

if __name__=="__main__":

    import matplotlib.pyplot as plt
    # locations = np.loadtxt('inputfiles/AnholtOffshoreWindFarmLocations.txt')
    locations = np.loadtxt('inputfiles/horns_rev_locations.txt',delimiter=",")
    turbine_x = locations[:, 0]
    turbine_y = locations[:, 1]
    plt.plot(turbine_x, turbine_y, 'o')

    nturbines = len(turbine_x)
    vertices = np.zeros((nturbines,2))
    for i in range(nturbines):
        vertices[i,0] = turbine_x[i]
        vertices[i,1] = turbine_y[i]

    vertices, normals = calculate_boundary(vertices)
    vert_x = vertices[:,0]
    vert_y = vertices[:,1]
    vert_x = np.append(vert_x,vert_x[0])
    vert_y = np.append(vert_y,vert_y[0])
    plt.plot(vert_x,vert_y)

    print repr(vertices)
    print repr(normals)
    plt.show()
