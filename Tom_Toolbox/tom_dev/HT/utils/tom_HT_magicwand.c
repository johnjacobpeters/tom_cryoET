/*******************************************************************************/
/*                                                                             */
/* MAGICWAND						                       */
/*	Given an image and a pixel cooridinate, this function isolates all     */
/*	neighboring pixels with values within a preset tolerance. This function*/
/*  mimics the behavoir of Adobe's Photoshop magic wand tool.                  */
/*                                                                             */
/* Synopsis:                                                                   */
/*	Y=magicwand(X, m, n);                                                  */
/*		Y=output image of type uint8(logical)			       */
/*		X=input image of type double				       */
/*		m=pixel cooridinate(row)				       */
/*		n=pixel cooridinate(col)				       */
/*                                                                             */
/*	Y=magicwand(X, m, n, Tol);					       */
/*		Tol=Tolerance value for locating pixel neighbors(default=0.01) */
/*                                                                             */
/*	Y=magicwand(X, m, n, Tol, eight_or_four);			       */
/*		eight_or_four=string such that if =='eigh', magicwand locates  */
/*		all eight-neighborhood pixels (default=four-neighborhood)      */
/*                                                                             */
/* Daniel Leo Lau                                                              */
/* lau@ece.udel.edu                                                            */
/*                                                                             */
/* Copyright April 7, 1997                                                     */
/*                                                                             */
/*                                                                             */
/* June 30 2003                                                                */
/* ------------                                                                */
/* Adapted to   MATLAB 6.5   (sorry, no backward compatibility)                */
/* Some changes in the main function due to the change in the definition of    */
/* logical variables in v6.5.                                                  */
/*                                                                             */
/* Yoram Tal                                                                   */
/* yoramtal123@yahoo.com                                                       */
/*******************************************************************************/

#include <math.h>
#include <string.h>
#include "mex.h"

/*******************************************************************************/
/*                                                                             */
/* MAGICWAND: performs the search of all neighboring pixels to the top, left,  */
/*	      bottom, and right of pixel(m,n).				                       */
/*                                                                             */
/*******************************************************************************/
void magic_wand(unsigned char Y[], double X[], int M, int N, int m, int n, double Tol)
{
        int r,s,t, *pixel_list_M, *pixel_list_N, length_pixel_list;
        int first_previous_iteration, last_previous_iteration, next_available_slot;
        double fixed_level;

        length_pixel_list=M*N;
        fixed_level=X[m+n*M];
        pixel_list_M=(int*)mxCalloc(length_pixel_list, sizeof(int));
        pixel_list_N=(int*)mxCalloc(length_pixel_list, sizeof(int));
        Y[m+n*M]=1;

        pixel_list_M[0]=m;
        pixel_list_N[0]=n;
        first_previous_iteration=0;
        last_previous_iteration=0;
        next_available_slot=1;
        while(1){
                for (r=first_previous_iteration; r<=last_previous_iteration; r++){
                        s=pixel_list_M[r]-1; t=pixel_list_N[r];
                        if (s>=0 && Y[s+t*M]!=1 && (fabs(fixed_level-X[s+t*M])<=Tol)){
                                pixel_list_M[next_available_slot]=s;
                                pixel_list_N[next_available_slot]=t;
                                Y[s+t*M]=1;
                                next_available_slot++;
                                if (next_available_slot==length_pixel_list) break;
                                }
                        s=pixel_list_M[r]; t=pixel_list_N[r]-1;
                        if (t>=0 && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
                                pixel_list_M[next_available_slot]=s;
                                pixel_list_N[next_available_slot]=t;
                                Y[s+t*M]=1;
                                next_available_slot++;
                                if (next_available_slot==length_pixel_list) break;
                                }
                        s=pixel_list_M[r]+1; t=pixel_list_N[r];
                        if (s<M && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
                                pixel_list_M[next_available_slot]=s;
                                pixel_list_N[next_available_slot]=t;
                                Y[s+t*M]=1;
                                next_available_slot++;
                                if (next_available_slot==length_pixel_list) break;
                                }
                        s=pixel_list_M[r]; t=pixel_list_N[r]+1;
                        if (t<N && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
                                pixel_list_M[next_available_slot]=s;
                                pixel_list_N[next_available_slot]=t;
                                Y[s+t*M]=1;
                                next_available_slot++;
                                if (next_available_slot==length_pixel_list) break;
                                }

                        }
                if (next_available_slot==length_pixel_list) break;
                if (last_previous_iteration==next_available_slot-1) break;
                first_previous_iteration=last_previous_iteration+1;
                last_previous_iteration=next_available_slot-1;
                }
        mxFree(pixel_list_M);
        mxFree(pixel_list_N);
        return;
}

/*******************************************************************************/
/*                                                                             */
/* MAGICWAND8: performs the search of all neighboring pixels to the top, left, */
/*	      bottom, right, and diaganols of pixel(m,n).		                   */
/*                                                                             */
/*******************************************************************************/
void magic_wand_8(unsigned char Y[], double X[], int M, int N, int m, int n, double Tol)
{
	int r,s,t, *pixel_list_M, *pixel_list_N, length_pixel_list;
	int first_previous_iteration, last_previous_iteration, next_available_slot;
	double fixed_level;

	mexPrintf("MAGIC WAND *\n");
	length_pixel_list=M*N;
	fixed_level=X[m+n*M];
	pixel_list_M=(int*)mxCalloc(length_pixel_list, sizeof(int));
	pixel_list_N=(int*)mxCalloc(length_pixel_list, sizeof(int));
	Y[m+n*M]=1;

	pixel_list_M[0]=m;
	pixel_list_N[0]=n;
	first_previous_iteration=0;
	last_previous_iteration=0;
	next_available_slot=1;
	while(1){
		for (r=first_previous_iteration; r<=last_previous_iteration; r++){
                        s=pixel_list_M[r]-1; t=pixel_list_N[r]-1;
                        if (s>=0 && t>=0 && Y[s+t*M]!=1 && (fabs(fixed_level-X[s+t*M])<=Tol)){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
			s=pixel_list_M[r]-1; t=pixel_list_N[r];
			if (s>=0 && Y[s+t*M]!=1 && (fabs(fixed_level-X[s+t*M])<=Tol)){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
                        s=pixel_list_M[r]-1; t=pixel_list_N[r]+1;
                        if (s>=0 && t<N && Y[s+t*M]!=1 && (fabs(fixed_level-X[s+t*M])<=Tol)){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
			s=pixel_list_M[r]; t=pixel_list_N[r]-1;
			if (t>=0 && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
			s=pixel_list_M[r]; t=pixel_list_N[r]+1;
			if (t<N && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
                        s=pixel_list_M[r]+1; t=pixel_list_N[r]-1;
                        if (s<M && t>=0 && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
			s=pixel_list_M[r]+1; t=pixel_list_N[r];
			if (s<M && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
                        s=pixel_list_M[r]+1; t=pixel_list_N[r]+1;
                        if (s<M && t<N && Y[s+t*M]!=1 && fabs(fixed_level-X[s+t*M])<=Tol){
				pixel_list_M[next_available_slot]=s;
				pixel_list_N[next_available_slot]=t;
				Y[s+t*M]=1;
				next_available_slot++;
				if (next_available_slot==length_pixel_list) break;
				}
			}
		if (next_available_slot==length_pixel_list) break;
		if (last_previous_iteration==next_available_slot-1) break;
		first_previous_iteration=last_previous_iteration+1;
		last_previous_iteration=next_available_slot-1;
		}
	mxFree(pixel_list_M);
	mxFree(pixel_list_N);
	return;
}

/*******************************************************************************/
/* mexFUNCTION                                                                 */
/* Gateway routine for use with MATLAB.                                        */
/*******************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        int M, N, m, n, output_dims[2];
        double *input_data, Tol;
	unsigned char *output_data, *int_input_data;
	char neighborhood[5];

        if (nrhs<3 || nrhs>5)
                mexErrMsgTxt("MAGICWAND requires three to five input arguments!");
        else if (nlhs>1)
                mexErrMsgTxt("MAGICWAND returns exactly one output argument!");
        else if (!mxIsNumeric(prhs[0]) ||
                  mxIsComplex(prhs[0]) ||
                  mxIsSparse(prhs[0]))
                mexErrMsgTxt("Input X must be a real matrix!");
        else if (!mxIsNumeric(prhs[1]) ||
                  mxIsComplex(prhs[1]) ||
                  mxIsSparse(prhs[1])  ||
                 !mxIsDouble(prhs[1]))
                mexErrMsgTxt("Input m must be a real scalar of type double!");
        else if (!mxIsNumeric(prhs[2]) ||
                  mxIsComplex(prhs[2]) ||
                  mxIsSparse(prhs[2])  ||
                 !mxIsDouble(prhs[2]))
                mexErrMsgTxt("Input n must be a real scalar of type double!");
	else if (nrhs>3 && !mxIsEmpty(prhs[3]) && (!mxIsNumeric(prhs[3]) ||
		              			    mxIsComplex(prhs[3]) ||
                  	      			    mxIsSparse(prhs[3])  ||
                             			   !mxIsDouble(prhs[3])))
		mexErrMsgTxt("Input TOL must be a real scalar!");
	else if (nrhs==5 && !mxIsChar(prhs[4]))
		mexErrMsgTxt("Input Neighborhood must be the string 'four' or 'eigh'!");


        M=mxGetM(prhs[0]);
        N=mxGetN(prhs[0]);
	if (mxIsDouble(prhs[0]))
		input_data=mxGetPr(prhs[0]);
	else if (mxIsUint8(prhs[0])){
		input_data=(double*)mxCalloc(M*N, sizeof(double));
		int_input_data=(unsigned char*)mxGetPr(prhs[0]);
		for (m=0; m<M*N; m++) input_data[m]=(double)int_input_data[m];
		}
	else    mexErrMsgTxt("Input X must be of type double or uint8!");

	m=mxGetScalar(prhs[1])-1;
	n=mxGetScalar(prhs[2])-1;
	if (m<0 || m>=M || n<0 || n>=N)
		mexErrMsgTxt("Invalid cooridinates m and n!");
	if (nrhs==3 || mxIsEmpty(prhs[3])) Tol=0.01; else Tol=mxGetScalar(prhs[3]);

	output_dims[0]=M; output_dims[1]=N;
/*  plhs[0]=mxCreateNumericArray(2, output_dims, mxUINT8_CLASS, mxREAL);
	mxSetLogical(plhs[0]); */
	plhs[0]= mxCreateLogicalMatrix(M, N);
        output_data=(unsigned char*)mxGetLogicals(plhs[0]);

	if (nrhs==5){
		mxGetString(prhs[4], neighborhood, 5);
		if (neighborhood[0]==101 && neighborhood[1]==105 && neighborhood[2]==103 && neighborhood[3]==104)
			magic_wand_8(output_data, input_data, M, N, m, n, Tol);
		else    magic_wand(output_data, input_data, M, N, m, n, Tol);
		}
	else
		magic_wand(output_data, input_data, M, N, m, n, Tol);
        return;
}
