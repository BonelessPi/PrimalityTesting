# Basic deterministic test for primality (brute-force)

function trial_division_basic(n::Integer)::Bool
    if n<2
        return false
    end
    for i in 2:n-1
        if n%i==0
            return false
        end
    end
    return true
end

function trial_division_improved(n::Integer; limit::Integer=isqrt(n))::Bool
    if n<2
        return false
    elseif n==2 || n==3
        return true
    elseif iseven(n)
        return false
    end

    for i in 3:2:limit
        if n%i==0
            return false
        end
    end
    return true
end

# Fermat primality test

function _fermat_trial(n::Integer, a::Integer)::Bool
    return powermod(a,n-1,n) == 1
end

function fermat_test(n::Integer; bases::Vector{T} where T <: Integer)::Bool
    if n<2
        return false
    elseif n==2 || n==3
        return true
    elseif iseven(n)
        return false
    end

    for a in bases
        if !_fermat_trial(n,a)
            return false
        end
    end
    return true
end

function fermat_test(n::Integer, k::Integer=8)::Bool
    # Yes this beginning part is required, otherwise n<4 throws an error on the rand call
    if n<2
        return false
    elseif n==2 || n==3
        return true
    elseif iseven(n)
        return false
    end

    return fermat_test(n, bases=rand(2:n-2,k))
end

# Miller-Rabin test

function _miller_rabin_trial(n::Integer, a::Integer, s::Integer, d::Integer)::Bool
    # n-1 = (2^s)*d, d is odd, n is odd
    x = powermod(a,d,n)
    if x == 1
        # If a^d == 1 mod n, then a^(2^s*d) == 1 mod n
        return true
    end
    for _ in 1:s
        # Note: x != 1 mod n
        y = powermod(x,2,n)
        if y == 1
            # For prime n, the only square roots of 1 mod n are +1,-1 mod n
            # Thus either x == -1 mod n or n is not prime
            return x == n-1
        end
        x = y
    end
    return x == 1
end

function _miller_rabin_trial(n::Integer, a::Integer)::Bool
    s = trailing_zeros(n-1)
    d = (n-1)>>s
    return _miller_rabin_trial(n,a,s,d)
end

function miller_rabin_test(n::Integer; bases::Vector{T} where T <: Integer)::Bool
    if n<2
        return false
    elseif n==2 || n==3
        return true
    elseif iseven(n)
        return false
    end

    s = trailing_zeros(n-1)
    d = (n-1)>>s
    for a in bases
        if !_miller_rabin_trial(n,a,s,d)
            return false
        end
    end
    return true
end

function miller_rabin_test(n::Integer, k::Integer=25)::Bool
    # Yes this beginning part is required, otherwise n<4 throws an error on the rand call
    if n<2
        return false
    elseif n==2 || n==3
        return true
    elseif iseven(n)
        return false
    end

    return miller_rabin_test(n, bases=rand(2:n-2,k))
end

# Deterministic versions with predetermined bases
# Need to see if n is in the bases first
# (Int8 and Int16 overloads don't need to change as n=2,3 are checked by the test already)
function miller_rabin_test(n::Int8)::Bool
    return miller_rabin_test(n, bases=[2])
end

function miller_rabin_test(n::Int16)::Bool
    return miller_rabin_test(n, bases=[2,3])
end

function miller_rabin_test(n::Int32)::Bool
    bases = [2,7,61]
    return insorted(n,bases) || miller_rabin_test(n, bases=bases)
end

function miller_rabin_test(n::Int64)::Bool
    bases = [2,3,5,7,11,13,17,19,23,29,31,37]
    return insorted(n,bases) || miller_rabin_test(n, bases=bases)
end


