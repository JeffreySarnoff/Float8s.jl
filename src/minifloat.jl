#=
from wikipedia minifloat

A minifloat is describable using a tuple of four numbers,
 (S, E, M, B):

    S is the length of the sign field. It is usually either 0 or 1.
    E is the length of the exponent field.
    M is the length of the mantissa (significand) field.
    B is the exponent bias.

A minifloat format denoted by (S, E, M, B) is, therefore,
 S + E + M bits long.

In computer graphics minifloats are sometimes used to represent only integral values. 
  If at the same time subnormal values should exist, 
    the least subnormal number has to be 1. 
  The bias value would be B = E - M - 1 in this case, 
    assuming two special exponent values are used per IEEE.

The (S, E, M, B) notation can be converted to a
 (B, P, L, U) format as (2, M + 1, B + 1, 2S - B)
 (with IEEE use of exponents). 
 B is 2, the base
 P is the precision to P numbers,
 L is the smallest exponent representable
 U is the largest exponent representable

 SESB(1, 6, 1, -15)
 BPLU(2, 2, 0,  3)

 SESB(1, 5, 2, -7)
 BPLU(2, 3, -2, 5)

 SESB(1, 4, 3, -3)
 BPLU(2, 4, -6, -5)

 SESB(1, 3, 4,  -1)
 BPLU(2, 4, -6, -5)

 using E4S3

zero
 0 0000 000 = 0

infinity
 0 1111 000 = +infinity
 1 1111 000 = −infinity

NaN
 1 1111 111 = NaN (if yyy ≠ 000)

subnormals
  The significand is extended with "0.":

  0 0000 001 = 0.0012 × 2x = 0.125 × 2x = 1 (least subnormal number)
  ...
  0 0000 111 = 0.1112 × 2x = 0.875 × 2x = 7 (greatest subnormal number)

=#

struct SESB # bits per field
    sign::Int8
    exponent::Int8
    significand::Int8
    bias::Int8
end


struct BPLU
    base::Int8
    prec::Int8
    maxe::Int8
    mine::Int8
end

BPLU(x::SESB) = BPLU(Int8(2), x.significand + Int8(1), x.bias + Int8(1), IN * x.significand - x.bias)


struct MINIFP
    base::Int8 # radix
    bits::Int8 # bitwidth
    expo::Int8 # exponent bits
    bias::Int8 # exponent bias
    prec::Int8 # precision (significand bits)
    mine::Int8 # smallest exponent
    maxe::Int8 # largest exponent

    zero::UInt8 # 0b0000_0000
    nan::UInt8  # 0b1111_1111
    pinf::UInt8 # +infinity
    ninf::UInt8 # -infinity
end

function MINIFP(x::SESB)
    base = Int8(2)
    bits = Int8(8)
    expo = x.exponent
    bias = x.bias
    prec = x.significand + Int8(1)
    mine = x.bias + Int8(1)
    maxe = Int8(2) * x.significand - x.bias

    zero = 0b0000_0000
    nan  = 0b1111_1111
    pinf = ((0b000_0001 << expo) - 1) << (7-expo)
    ninf = pinf | 0b1000_0000

    MINIFP(base, bits, expo, bias, prec, mine, maxe,
           zero, nan, pinf, ninf)
end
