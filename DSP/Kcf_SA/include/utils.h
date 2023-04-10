/**
 * @file utils.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _UTILS_H_
#define _UTILS_H_

#include <cv.h>
#include <c6x.h>

extern const double ti_math_kTable[4];
extern const double ti_math_jTable[4];
extern const float boundary_x[9];
extern const float boundary_y[9];
extern const float factors[64];

/**
 * @brief calculate dx, dy and x*x
 * 
 * @param pSrc 
 * @param pDxDy 
 * @param pSqr 
 * @return int 
 */
int calcDiff(const CvMat *pSrc, CvMat *pDxDy, CvMat *pSqr);

/**
 * @brief Get the Feature Maps object
 * 
 * @param pSubw have not resized image CV_32FC1
 * @param pMap 1024x27 CV_32C1
 * @return int 0 for OK
 */
int getFeatureMaps(const CvMat *pSubw, CvMat *pMap);

/**
 * @brief normalize feature map and truncate
 * 
 * @param pFM 1024x27 CV_32FC1
 * @param pNorm 1024x108 CV_32FC1
 * @return int 0 for OK
 */
int normalizeAndTruncate(const CvMat *pFM, CvMat *pNorm);

/**
 * @brief PCA feature maps and transpose
 * 
 * @param pNorm 1024x108 CV_32FC1
 * @param pPca 1024x31 CV_32FC1
 * @return int 0 for OK
 */
int PCAFeatureMaps(const CvMat *pNorm, CvMat *pPca);

static inline float cossp_i (float a)
{
    float   Zero   =  0.0f; 
    float   MAX    =  1048576.0f;
    float   MIN    =  2.4414062e-4f;
    float   Sign   =  1.0f;
    float   InvPI  =  0.318309886183791f;
    float	  HalfPI =  1.5707963268f;
    float   s4     =  2.601903036e-6f;
    float   s3     = -1.980741872e-4f;
    float   s2     =  8.333025139e-3f;
    float   s1     = -1.666665668e-1f;
    float   C1     =  3.140625f;
    float   C2     =  9.67653589793e-4f;
    float   X, Y, Z, F, G, R, res;
    int     N;

    Y = _fabsf(a) + HalfPI;

    if (Y > MAX) {
        Y = HalfPI;
    }

    /*-----------------------------------------------------------------------*/
    /*  X = |a|/PI + 1/2                                                     */
    /*-----------------------------------------------------------------------*/
    /*  when rounded to the nearest integer yields the signedness of cos(a)  */
    /*     e.g.                                                              */
    /*  positive (rounds to odd number):  a=0 --> 1/2       a=pi/2 --> 1     */
    /*  negative (rounds to even number): a=pi -> 3/2       a=3pi/2 -> 2     */
    /*-----------------------------------------------------------------------*/

    X = Y * InvPI;            /* X = Y * (1/PI)         */
    N = _spint(X);            /* N = X, rounded to nearest integer */
    Z = (float)N;                    /* Z = float (N)          */

    /* opposite of final sign */
    if ((N%2) != 0) {
        Sign = -Sign;           /* quad. 3 or 4   */
    }

    F = (Y - (Z*C1)) - (Z*C2);
    R = F;

    if (F < Zero) {
        R = -R;
    }

    if (R < MIN) {
        res = R*Sign;
    } else {
        G = F*F;
        R = ((((((s4*G) + s3)*G) + s2)*G) + s1)*G;
        res = (F + (F*R))*Sign;
    }

    return res;
}

static inline float expsp_i (float x)
{
  const float log2_base_x16 =  23.083120654f;  /*1.442695041 * 16*/
  const float half         =   0.5f;
  const float LnMin        =  -87.33654475f;
  const float LnMax        =   88.72283905f;
  const float Max          =   3.402823466E+38f;
  const double p           =   0.0433216987816623;  /* 1/log2_base_x16 */

  /* coefficients to approximate the decimal part of the result */
  const float c0           =   0.166668549286041f;
  const float c1           =   0.500016170012920f;
  const float c2           =   0.999999998618401f;

  float pol, r, r2, r3,res;
  unsigned int Ttemp, J, K;
  float	       Nf;
  int          N ;
  double       dT;

  /* Get N such that |N - x*16/ln(2)| is minimized */
  Nf = (x * log2_base_x16) + half;
  N  = (int) Nf; /* Cast from intermediate variable to appease MISRA */
  
  if ((x * log2_base_x16) < - half) {
    N--;
  }

  /* Argument reduction, r, and polynomial approximation pol(r) */
  r  = (float) ((double)x - (p * (double)N)) ;
  r2 = r * r;
  r3 = r * r2;

  pol = (r * c2) + ((r3 * c0) + (r2 * c1));
  
  /* Get index for ktable and jtable */
  K  = _extu ((unsigned int)N, 28u, 30u);
  J  = (unsigned int)N & 0x3u;
  dT = ti_math_kTable[K] * ti_math_jTable[J];

  /* Scale exponent to adjust for 2^M */
  Ttemp =  _hi(dT) + (((unsigned int) N >> 4) << 20);
  dT    = _itod(Ttemp, _lo(dT));

  res = (float)dT * (1.0f + pol);

  /* < LnMin returns 0 */
  if (x < LnMin) {
    res = 0.0f;
  }

  /* > LnMax returns MAX */
  if (x > LnMax) {
    res = Max;
  }

  return(res);
}

static inline float divsp_i (float a, float b)
{
    float TWO  = 2.0f;
    float Maxe = 3.402823466E+38f;
    float X;

    X = _rcpsp(b);
    X = X*(TWO - (b*X));
    X = X*(TWO - (b*X));
    X = a*X;

    if (a == 0.0f) {     
        X = 0.0f;
    }
    
    if ((_fabsf(b) > Maxe) && (_fabs(a) <= Maxe)) {     
        X = 0.0f;
    }
    
    return (X);
}

static void sqrtsp_v (const float a[restrict], float output[restrict], int size)
{
    const float  Half  = 0.5f;
    const float  OneP5 = 1.5f;
    float x, x1, x2, y;
    int i;  

    /* Vector loop */
    for (i = 0; i < size; i++) {
        x = a[i];

        x1 = _rsqrsp(x);

        x2 = x1 * (OneP5 - (x * x1*x1*Half));
        x2 = x2 * (OneP5 - (x * x2*x2*Half));
        y = x*x2;

        if (x <= 0.0f) {
        y = 0.0f;
        }
        if (x > FLT_MAX) {
        y = FLT_MAX;
        }

        output[i] = y;
    }
}

static inline float subPixelPeak(float left, float center, float right)
{
    float den = center*2 - left - right;

	if (den == 0)
        return 0;
    
    return 0.5 * (right - left) / den;
}

#endif
