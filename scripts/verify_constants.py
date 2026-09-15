"""Derive every modular constant the RTL uses."""
import sys

Q = 3329          # FIPS 203 modulus
R = 1 << 16       # Montgomery radix
XBITS = 24        # reducer input width -- this IS the precondition

failures = 0

def check(name, got, verify_ok, note=""):
    global failures
    status = "OK" if verify_ok else "FAIL"
    if not verify_ok:
        failures += 1
    print(f"  {name:<28} {got:<12} {status}  {note}")

r_inv = pow(R, -1, Q)
check("R^-1 mod q", r_inv, R * r_inv % Q == 1, "golden model multiplier")

# TODO: q_neg_inv  -> pairs with ADD
# TODO: q_pos_inv  -> pairs with SUB
# TODO: t_max, its bit_length()
# TODO: t_max >> 16, assert < 2*Q

if failures:
    print(f"  {failures} CONSTANT MISMATCH(ES)")
    sys.exit(1)
print("  all constants verified")