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
    if((uint64_t)R * R_INV % Q != 1) {
        bad++;
        printf("FAIL: R * R_INV mod Q = %llu, expected 1\n");
    }

    return bad;
}
