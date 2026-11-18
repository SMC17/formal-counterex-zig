# formal-counterex

**[Status](STATUS.md) · [Roadmap](ROADMAP.md) · [Contributing](CONTRIBUTING.md) · [Issues](https://github.com/SMC17/formal-counterex-zig/issues) · [Public roadmap](https://github.com/users/SMC17/projects/16)**

A small CLI over a machine-checked database of quantitative-finance claims that
were either **refuted by a formal counterexample** or **confirmed by a formal
proof** in Lean 4 / Mathlib. Discipline over folklore: each verdict is settled
by a kernel-checked artifact, not by appeal to authority.

## Why

Practitioner intuition is often *almost* right in a way that fails at the edge —
the sign flip, the negative-`c` scaling, the unbounded tail. Publishing the
refutations, not only the confirmations, is the honest half of the ledger.

## Build & run

Requires Zig 0.16.

```
zig build
zig build test          # 5/5

./zig-out/bin/formal-counterex list-refuted
./zig-out/bin/formal-counterex check es_is_coherent      # CONFIRMED
./zig-out/bin/formal-counterex check cvar_is_coherent    # REFUTED
```

## The seven refutations

| Claim (as commonly stated) | Why it's false |
|---|---|
| `cvar_is_coherent` | Naive tail-integral CVaR fails translation invariance, monotonicity, and subadditivity on a Fin 3 uniform. Use ES (Rockafellar–Uryasev). |
| `sharpe_scale_invariant_all_c` | `SR(cX) = -SR(X)` for `c < 0`; Sharpe is scale-invariant only under positive scaling. |
| `diversification_always_reduces_variance` | Positively correlated assets can produce combined variance exceeding either leg. |
| `kelly_maximizes_expected_wealth` | Kelly maximizes `E[log W]`, not `E[W]`; bet-everything dominates `E[W]` with ruin probability 1. |
| `max_sharpe_always_equal_weights` | Max-Sharpe weights depend on inverse covariance and excess returns; equal weights are optimal only under full symmetry. |
| `all_martingales_bounded` | A symmetric random walk is an unbounded martingale (`limsup +∞`, `liminf −∞` a.s.). |
| `es_symmetric_in_alpha` | `ES(α) ≠ ES(1−α)` in general; equal only for symmetric zero-mean distributions. |

The manifest also carries 40 standard results confirmed by formal proof
(ES coherence, put–call parity, Cramér–Rao, Gale–Shapley stability,
VCG strategy-proofness, …). `check <claim>` reports `CONFIRMED`, `REFUTED`, or
`UNKNOWN/PENDING`.

## Data

The claim database is published as a Hugging Face dataset:
[**seancollins/formal-refutations**](https://huggingface.co/datasets/seancollins/formal-refutations)
(7 refutations + 40 confirmations, JSONL). Provenance: Lean 4 / Mathlib.

## License

Apache-2.0.
