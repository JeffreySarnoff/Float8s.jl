using Quadmath

rational(x::AbstractFloat) = rationalize(x, tol=eps(x/2))

function imodf(x::T) where {T<:AbstractFloat}
    mfr, mi = modf(x)
    mfri = mfr * 2^precision(T)
    if !isinteger(mfri)
        error("expecting an integer not $(mfri)")
    end
    mfi = Int128(mfri)
    mq = mfi // 2^precision(T)
    mfq = mq + Int128(mi)
    mfq
end

