#include "mex.h"
#include "mexutil.h"

/*
 *  z = repmultiply(y,x)
 *
 * Multiply an input vector with an input matrix 
 *
 * Written by Masa-aki Sato 2007/07/01
 */

/* 
   z(m,n) = x * y(m,n)
   x : 1 x 1, y : M x N
 */
void xtimesy(double x, double *y, double *z, int m, int n)
{
  int i,j,count=0;
  
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      *(z+count) = x * *(y+count);
      count++;
    }
  }
}

/* 
   z(m,n) = x(n) * y(m,n)
   x : 1 x N, y : M x N
   (mx==1 && nx==ny)
 */
void xtimesyrow(double *x, double *y, double *z, int m, int n)
{
  int i,j,count=0;
  
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      *(z+count) = *(x+i) * *(y+count);
      count++;
    }
  }
}

/* 
   z(m,n) = x(m) * y(m,n)
   x : M x 1, y : M x N
   (nx==1 && mx==my)
 */
void xtimesycol(double *x, double *y, double *z, int m, int n)
{
  int i,j,count=0;
  
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      *(z+count) = *(x+j) * *(y+count);
      count++;
    }
  }
}

/* 
   z(m,n) = x(m,n) * y(m,n)
   x : M x N, y : M x N
   (nx==ny && mx==my)
 */
void xtimesyall(double *x, double *y, double *z, int m, int n)
{
  int i,j,count=0;
  
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      *(z+count) = *(y+count) * *(x+count);
      count++;
    }
  }
}


/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	double *x, *y,*z;
	int    mx,my,nx,ny;
	
	/*  Check for proper number of arguments. */
	if(nrhs!=2) 
	  mexErrMsgTxt("Two inputs required.");
	if(nlhs!=1) 
	  mexErrMsgTxt("One output required.");
	
	/*  Create a pointer to the input y. */
	y = mxGetPr(prhs[0]);
	
	/*  Get the dimensions of the matrix input y. */
	my = mxGetM(prhs[0]);
	ny = mxGetN(prhs[0]);

	/*  Create a pointer to the input x. */
	x = mxGetPr(prhs[1]);
	
	/*  Get the dimensions of the matrix input x. */
	mx = mxGetM(prhs[1]);
	nx = mxGetN(prhs[1]);
	
	/*  Set the output pointer to the output matrix. 
		plhs[0] = mxCreateDoubleMatrix(my,ny, mxREAL);
		Create uninitialized matrix for speed up
	*/
	plhs[0] = mxCreateDoubleMatrixE(my,ny,mxREAL);
	
	/*  Create a C pointer to a copy of the output matrix. */
	z = mxGetPr(plhs[0]);
	
	if (mx==1 && nx==ny){
		xtimesyrow(x,y,z,my,ny);
		}
	else if (nx==1 && mx==my){
		xtimesycol(x,y,z,my,ny);
		}
	else if (nx==ny && mx==my){
		xtimesyall(x,y,z,my,ny);
		}
	else if (nx==1 && mx==1){
		xtimesy(*x,y,z,my,ny);
		}
	else {
	    mexErrMsgTxt("Do not match dim");
	}

}
