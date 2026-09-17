#include <cstdint>
#include <cstdio>
#include <cmath>

static const uint32_t Q     = 3329;
static const uint32_t R     = 1u << 16;
static const uint32_t R_INV = 169;    // R^-1 mod q 


inline uint32_t mont_reduce_ref(uint32_t x) {
    return (uint32_t)((uint64_t)x * R_INV % Q);
}


inline int check_constants() {
    int bad = 0;
    // verify R * R_INV mod Q == 1
    if(mont_reduce_ref(R) != 1) {
        bad++;
        printf("R * R_INV mod Q != 1\n");
    }
    // verify R_INV is actually 169
    if(R_INV != (uint32_t)(R^-1 % Q)) {
        bad++;
        printf("R_INV is not 169\n");
    }

    return bad;
}