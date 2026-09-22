#pragma once

#include <cstdint>
#include <cstdio>

static const uint32_t Q     = 3329;
static const uint32_t R     = 1u << 16;
static const uint32_t R_INV = 169;    // R^-1 mod q 


inline uint32_t mont_reduce_ref(uint32_t x) {
    return (uint32_t)((uint64_t)x * R_INV % Q);
}


inline int check_constants() {
    int bad = 0;

    // verify R_INV is actually 169
    uint32_t check = (uint64_t)R * R_INV % Q;
    if(check != 1) {
        bad++;
        printf("FAIL: R * R_INV mod Q = %llu, expected 1\n", (unsigned long long)check);
    }

    return bad;
}


inline void butterfly_ref(uint32_t a, uint32_t b, uint32_t zeta, uint32_t& a_out, uint32_t& b_out) {
    uint32_t t = mont_reduce_ref(b * zeta);
    a_out = (a + t) % Q;
    b_out = (a + Q - t) % Q;
}