#include "fft.h"
#include "math.h"

unsigned char brev[64] = {
    0x0, 0x20, 0x10, 0x30, 0x8, 0x28, 0x18, 0x38,
    0x4, 0x24, 0x14, 0x34, 0xc, 0x2c, 0x1c, 0x3c,
    0x2, 0x22, 0x12, 0x32, 0xa, 0x2a, 0x1a, 0x3a,
    0x6, 0x26, 0x16, 0x36, 0xe, 0x2e, 0x1e, 0x3e,
    0x1, 0x21, 0x11, 0x31, 0x9, 0x29, 0x19, 0x39,
    0x5, 0x25, 0x15, 0x35, 0xd, 0x2d, 0x1d, 0x3d,
    0x3, 0x23, 0x13, 0x33, 0xb, 0x2b, 0x1b, 0x3b,
    0x7, 0x27, 0x17, 0x37, 0xf, 0x2f, 0x1f, 0x3f
};

/*
    The main function that implements the example functionality.
    This example demonstrates the usage of the various FFT kernels provided
    with the C6x DSPLIB. The example shows:
        - Twiddle factor generation for the various kernels
        - Needed scaling to get correct output
        - Demonstrates usage of FFT APIs
*/

/* Function for generating Specialized sequence of twiddle factors */
void gen_twiddle_fft_sp (float *w, int n)
{
    int i, j, k;
    const double PI = 3.141592654;

    for (j = 1, k = 0; j <= n >> 2; j = j << 2)
    {
        for (i = 0; i < n >> 2; i += j)
        {
#ifdef _LITTLE_ENDIAN
            w[k] = (float) sin (2 * PI * i / n);
            w[k + 1] = (float) cos (2 * PI * i / n);
            w[k + 2] = (float) sin (4 * PI * i / n);
            w[k + 3] = (float) cos (4 * PI * i / n);
            w[k + 4] = (float) sin (6 * PI * i / n);
            w[k + 5] = (float) cos (6 * PI * i / n);
#else
            w[k] = (float) cos (2 * PI * i / n);
            w[k + 1] = (float) -sin (2 * PI * i / n);
            w[k + 2] = (float) cos (4 * PI * i / n);
            w[k + 3] = (float) -sin (4 * PI * i / n);
            w[k + 4] = (float) cos (6 * PI * i / n);
            w[k + 5] = (float) -sin (6 * PI * i / n);
#endif
            k += 6;
        }
    }
}
