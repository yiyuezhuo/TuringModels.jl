using StatisticalRethinking
using Turing
using StatsFuns #logistic

Turing.setadbackend(:reverse_diff)

d = CSV.read(joinpath(dirname(Base.pathof(StatisticalRethinking)), "..", "data",
    "UCBadmit.csv"), delim=';')
size(d) # Should be 12x5

# Change male/female to 1/0
d[:admit] = map(x -> ifelse(x=="male", 1, 0), d[:admit])

@model m11_5(admit, applications) = begin
    N=length(admit)
    θ ~ Truncated(Exponential(1), 0, Inf)
    α ~ Normal(0,2)

    for i ∈ 1:N
        prob = logistic(α)

        # alpha and beta for the distribution must be provided
        # The two parameterizations are related by
        # alpha = prob * theta, beta = (1-prob) * theta.
        alpha = prob * θ
        beta = (1-prob) * θ

        admit[i] ~ BetaBinomial(N, alpha, beta)
    end
end

posterior = sample(m11_5(d[:admit], d[:applications]), Turing.NUTS(4000, 1000, 0.95))
describe(posterior)
#             Mean          SD        Naive SE       MCSE        ESS
#        α  -2.168236419  0.478131458 0.0075599221 0.048595163   96.807399
#        θ   3.150233868  1.599696366 0.0252934204 0.149353822  114.720871

# Rethinking
#        mean   sd  5.5% 94.5% n_eff Rhat
# theta  2.74 0.96  1.43  4.37  3583    1
# a     -0.37 0.31 -0.87  0.12  3210    1
