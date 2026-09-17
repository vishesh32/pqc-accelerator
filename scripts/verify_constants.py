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

q_pos_inv = pow(Q,-1,R) # +q^-1 mod 2^16
q_neg_inv = (-q_pos_inv) % R # -q^-1 mod 2^16
# TODO: q_neg_inv  -> pairs with ADD
check("-q^-1 mod 2^16", q_neg_inv, Q * q_neg_inv % R == R - 1,  "pairs with ADD")
# TODO: q_pos_inv  -> pairs with SUB
check("+q^-1 mod 2^16", q_pos_inv, Q * q_pos_inv % R == 1,      "pairs with SUBTRACT")

# TODO: t_max, its bit_length()
x_max = (1 << XBITS) - 1
m_max = R - 1
t_max = x_max + m_max * Q
check("t_max bit width", t_max.bit_length(), t_max.bit_length() == 28, "wire width in RTL")
# TODO: t_max >> 16, assert < 2*Q
t_shifted_max = t_max >> 16
check("max t>>16 < 2q", t_shifted_max, t_shifted_max < 2 * Q, f"{t_shifted_max} < {2*Q} = {t_shifted_max < 2*Q}")

if failures:
    print(f"  {failures} CONSTANT MISMATCH(ES)")
    sys.exit(1)
print("  all constants verified")
