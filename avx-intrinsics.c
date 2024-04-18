#include <immintrin.h>

float recip_f32(float x) {
    return _mm256_cvtss_f32(_mm256_rcp_ps(_mm256_set1_ps(x)));
}

float rsqrt_f32(float x) {
    return _mm256_cvtss_f32(_mm256_rsqrt_ps(_mm256_set1_ps(x)));
}

double recip_f64(double x) {
    return (double) recip_f32((double) x);
}

double rsqrt_f64(double x) {
    return (double) rsqrt_f32((double) x);
}