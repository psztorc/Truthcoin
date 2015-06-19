
# Almost exact translation of the ALGOL SVD algorithm published in
# Numer. Math. 14, 403-420 (1970) by G. H. Golub and C. Reinsch
#
# by Thomas R. Metcalf, helicity314-stitch <at> yahoo <dot> com
#
# Pure Python SVD algorithm.
# Input: 2-D list (m by n) with m >= n
# Output: U,W V so that A = U*W*VT
#    Note this program returns V not VT (=transpose(V))
#    On error, a ValueError is raised.
#
# Here is the test case (first example) from Golub and Reinsch
#
# a = [[22.,10., 2.,  3., 7.],
#      [14., 7.,10.,  0., 8.],
#      [-1.,13.,-1.,-11., 3.],
#      [-3.,-2.,13., -2., 4.],
#      [ 9., 8., 1., -2., 4.],
#      [ 9., 1.,-7.,  5.,-1.],
#      [ 2.,-6., 6.,  5., 1.],
#      [ 4., 5., 0., -2., 2.]]
#
# import svd
# import math
# u,w,vt = svd.svd(a)
# print w
#
# [35.327043465311384, 1.2982256062667619e-15,
#  19.999999999999996, 19.595917942265423, 0.0]
#
# the correct answer is (the order may vary)
#
# print (math.sqrt(1248.),20.,math.sqrt(384.),0.,0.)
#
# (35.327043465311391, 20.0, 19.595917942265423, 0.0, 0.0)
#
# transpose and matrix multiplication functions are also included
# to facilitate the solution of linear systems.
#
# Version 1.0 2005 May 01


import copy
from cdecimal import Decimal
ten=Decimal('10')
one=Decimal('1')
zero=Decimal('0')
half=Decimal('0.5')
def sqrt(n): return n**half#return sqrt_h(n, decimal.Decimal(1))
def svd(a):
    '''Compute the singular value decomposition of array.'''

    # Golub and Reinsch state that eps should not be smaller than the
    # machine precision, ie the smallest number
    # for which 1+e>1.  tol should be beta/e where beta is the smallest
    # positive number representable in the computer.
    eps = ten**(-15)# assumes double precision
    tol = (ten**(-64))/eps
    assert one+eps > one # if this fails, make eps bigger
    assert tol > zero     # if this fails, make tol bigger
    itmax = 50
    u = copy.deepcopy(a)
    m = len(a)
    n = len(a[0])
    #if __debug__: print 'a is ',m,' by ',n

    if m < n:
        if __debug__: print 'Error: m is less than n'
        raise ValueError,'SVD Error: m is less than n.'

    e = [zero]*n  # allocate arrays
    q = [zero]*n
    v = []
    for k in range(n): v.append([zero]*n)
 
    # Householder's reduction to bidiagonal form

    g = zero
    x = zero

    for i in range(n):
        e[i] = g
        s = zero
        l = i+1
        for j in range(i,m): s += (u[j][i]*u[j][i])
        if s <= tol:
            g = zero
        else:
            f = u[i][i]
            if f < zero:
                g = sqrt(s)
            else:
                g = -sqrt(s)
            h = f*g-s
            u[i][i] = f-g
            for j in range(l,n):
                s = zero
                for k in range(i,m): s += u[k][i]*u[k][j]
                f = s/h
                for k in range(i,m): u[k][j] = u[k][j] + f*u[k][i]
        q[i] = g
        s = zero
        for j in range(l,n): s = s + u[i][j]*u[i][j]
        if s <= tol:
            g = zero
        else:
            f = u[i][i+1]
            if f < zero:
                g = sqrt(s)
            else:
                g = -sqrt(s)
            h = f*g - s
            u[i][i+1] = f-g
            for j in range(l,n): e[j] = u[i][j]/h
            for j in range(l,m):
                s=zero
                for k in range(l,n): s = s+(u[j][k]*u[i][k])
                for k in range(l,n): u[j][k] = u[j][k]+(s*e[k])
        y = abs(q[i])+abs(e[i])
        if y>x: x=y
    # accumulation of right hand gtransformations
    for i in range(n-1,-1,-1):
        if g != zero:
            h = g*u[i][i+1]
            for j in range(l,n): v[j][i] = u[i][j]/h
            for j in range(l,n):
                s=zero
                for k in range(l,n): s += (u[i][k]*v[k][j])
                for k in range(l,n): v[k][j] += (s*v[k][i])
        for j in range(l,n):
            v[i][j] = zero
            v[j][i] = zero
        v[i][i] = one
        g = e[i]
        l = i
    #accumulation of left hand transformations
    for i in range(n-1,-1,-1):
        l = i+1
        g = q[i]
        for j in range(l,n): u[i][j] = zero
        if g != zero:
            h = u[i][i]*g
            for j in range(l,n):
                s=zero
                for k in range(l,m): s += (u[k][i]*u[k][j])
                f = s/h
                for k in range(i,m): u[k][j] += (f*u[k][i])
            for j in range(i,m): u[j][i] = u[j][i]/g
        else:
            for j in range(i,m): u[j][i] = zero
        u[i][i] += one
    #diagonalization of the bidiagonal form
    eps = eps*x
    for k in range(n-1,-1,-1):
        for iteration in range(itmax):
            # test f splitting
            for l in range(k,-1,-1):
                goto_test_f_convergence = False
                if abs(e[l]) <= eps:
                    # goto test f convergence
                    goto_test_f_convergence = True
                    break  # break out of l loop
                if abs(q[l-1]) <= eps:
                    # goto cancellation
                    break  # break out of l loop
            if not goto_test_f_convergence:
                #cancellation of e[l] if l>0
                c = zero
                s = one
                l1 = l-1
                for i in range(l,k+1):
                    f = s*e[i]
                    e[i] = c*e[i]
                    if abs(f) <= eps:
                        #goto test f convergence
                        break
                    g = q[i]
                    h = pythag(f,g)
                    q[i] = h
                    c = g/h
                    s = -f/h
                    for j in range(m):
                        y = u[j][l1]
                        z = u[j][i]
                        u[j][l1] = y*c+z*s
                        u[j][i] = -y*s+z*c
            # test f convergence
            z = q[k]
            if l == k:
                # convergence
                if z<zero:
                    #q[k] is made non-negative
                    q[k] = -z
                    for j in range(n):
                        v[j][k] = -v[j][k]
                break  # break out of iteration loop and move on to next k value
            if iteration >= itmax-1:
                if __debug__: print 'Error: no convergence.'
                # should this move on the the next k or exit with error??
                #raise ValueError,'SVD Error: No convergence.'  # exit the program with error
                break  # break out of iteration loop and move on to next k
            # shift from bottom 2x2 minor
            x = q[l]
            y = q[k-1]
            g = e[k-1]
            h = e[k]
            f = ((y-z)*(y+z)+(g-h)*(g+h))/(2*one*h*y)
            g = pythag(f,one)
            if f < 0:
                f = ((x-z)*(x+z)+h*(y/(f-g)-h))/x
            else:
                f = ((x-z)*(x+z)+h*(y/(f+g)-h))/x
            # next QR transformation
            c = one
            s = one
            for i in range(l+1,k+1):
                g = e[i]
                y = q[i]
                h = s*g
                g = c*g
                z = pythag(f,h)
                e[i-1] = z
                c = f/z
                s = h/z
                f = x*c+g*s
                g = -x*s+g*c
                h = y*s
                y = y*c
                for j in range(n):
                    x = v[j][i-1]
                    z = v[j][i]
                    v[j][i-1] = x*c+z*s
                    v[j][i] = -x*s+z*c
                z = pythag(f,h)
                q[i-1] = z
                c = f/z
                s = h/z
                f = c*g+s*y
                x = -s*g+c*y
                for j in range(m):
                    y = u[j][i-1]
                    z = u[j][i]
                    u[j][i-1] = y*c+z*s
                    u[j][i] = -y*s+z*c
            e[l] = zero
            e[k] = f
            q[k] = x
            # goto test f splitting
        
            
    #vt = transpose(v)
    #return (u,q,vt)
    return (u,q,v)

def pythag(a,b):
    absa = abs(a)
    absb = abs(b)
    if absa > absb: return absa*sqrt(one+(absb/absa)**2)
    else:
        if absb == zero: return zero
        else: return absb*sqrt(one+(absa/absb)**2)

def transpose(a):
    '''Compute the transpose of a matrix.'''
    m = len(a)
    n = len(a[0])
    at = []
    for i in range(n): at.append([zero]*m)
    for i in range(m):
        for j in range(n):
            at[j][i]=a[i][j]
    return at

def matrixmultiply(a,b):
    '''Multiply two matrices.
    a must be two dimensional
    b can be one or two dimensional.'''
    
    am = len(a)
    bm = len(b)
    an = len(a[0])
    try:
        bn = len(b[0])
    except TypeError:
        bn = 1
    if an != bm:
        raise ValueError, 'matrixmultiply error: array sizes do not match.'
    cm = am
    cn = bn
    if bn == 1:
        c = [zero]*cm
    else:
        c = []
        for k in range(cm): c.append([zero]*cn)
    for i in range(cm):
        for j in range(cn):
            for k in range(an):
                if bn == 1:
                    c[i] += a[i][k]*b[k]
                else:
                    c[i][j] += a[i][k]*b[k][j]
    
    return c
if __name__ == "__main__":
    a = [[22.,10., 2.,  3., 7.],
         [14., 7.,10.,  0., 8.],
         [-1.,13.,-1.,-11., 3.],
         [-3.,-2.,13., -2., 4.],
         [ 9., 8., 1., -2., 4.],
         [ 9., 1.,-7.,  5.,-1.],
         [ 2.,-6., 6.,  5., 1.],
         [ 4., 5., 0., -2., 2.]]
    a=map(lambda row: map( lambda x: Decimal(x), row), a)
    u,w,vt = svd(a)
    print w
    print([35.327043465311384, 1.2982256062667619e-15, 19.999999999999996, 19.595917942265423, 0.0])
