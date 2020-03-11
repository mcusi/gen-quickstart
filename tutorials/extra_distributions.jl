using Gen;
using Distributions;

### Computation of likelihood which scales linearly 
struct NoisyMatrix <: Gen.Distribution{Matrix{Float64}} end

const noisy_matrix = NoisyMatrix()

function Gen.logpdf(::NoisyMatrix, x::Matrix{Float64}, mu::Matrix{Float64}, noise::Float64)
    var = noise * noise
    diff = x - mu
    vec = diff[:]
    -(vec' * vec)/ (2.0 * var) - 0.5 * log(2.0 * pi * var)
end

function Gen.random(::NoisyMatrix, mu::Matrix{Float64}, noise::Float64)
    mat = copy(mu)
    (w, h) = size(mu)
    for i=1:w
        for j=1:h
            mat[i, j] = mu[i, j] + randn() * noise
        end
    end
    mat
end
Gen.has_output_grad(::NoisyMatrix) = false
Gen.has_argument_grads(::NoisyMatrix) = (false, false)
Gen.logpdf_grad(::NoisyMatrix, x, mu, noise) = (nothing, nothing, nothing)

"""
    TruncatedNormal(mu::Real,sigma::Real,l::Real)
Sample an `Real` from the Truncated Normal distribution with mu/sigma and lower limit l, upper limit u.
"""
struct TruncatedNormalG <: Gen.Distribution{Float64} end

const truncated_normal = TruncatedNormalG()

function Gen.logpdf(::TruncatedNormalG, x::Real, mu::Real, sigma::Real, l::Real, u::Real)
    Distributions.logpdf(Distributions.truncated(Distributions.Normal(mu, sigma), l, u), x)
end

function Gen.random(::TruncatedNormalG, mu::Real, sigma::Real, l::Real, u::Real)
    rand(Distributions.truncated(Distributions.Normal(mu, sigma), l, u)) 
end

Gen.has_output_grad(::TruncatedNormalG) = false
Gen.has_argument_grads(::TruncatedNormalG) = (false,false)
Gen.logpdf_grad(::TruncatedNormalG, x, a, b, l, u) = (nothing, nothing, nothing)