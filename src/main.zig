const std = @import("std");

const manifest_json = @embedFile("proof_manifest.json");

const Refutation = struct {
    claim: []const u8,
    reason: []const u8,
};

const refutations = [_]Refutation{
    .{ .claim = "cvar_is_coherent",
       .reason = "REFUTED 2026-06-27: naive tail-integral CVaR fails translation invariance, monotonicity, and subadditivity on Fin 3 uniform distribution. Use ES (Rockafellar-Uryasev) — es_is_coherent CONFIRMED." },
    .{ .claim = "sharpe_scale_invariant_all_c",
       .reason = "REFUTED: SR(c*X) = -SR(X) for c<0. Sharpe is only scale-invariant under positive scaling." },
    .{ .claim = "diversification_always_reduces_variance",
       .reason = "REFUTED: Positively correlated assets can produce combined variance exceeding either individual. Counterexample in QuantLib/Strategies/Portfolio.lean." },
    .{ .claim = "kelly_maximizes_expected_wealth",
       .reason = "REFUTED: Kelly maximizes E[log W_T], not E[W_T]. Bet-everything dominates in E[W] but has ruin probability 1. kelly_log_growth CONFIRMED." },
    .{ .claim = "max_sharpe_always_equal_weights",
       .reason = "REFUTED: Max-SR weights depend on inverse covariance and excess return vector. Equal weights optimal only under full symmetry." },
    .{ .claim = "all_martingales_bounded",
       .reason = "REFUTED: Symmetric random walk is a martingale with limsup = +inf, liminf = -inf a.s. random_walk_qv CONFIRMED." },
    .{ .claim = "es_symmetric_in_alpha",
       .reason = "REFUTED: ES(0.95) and ES(0.05) represent opposite tails. Equal only for symmetric zero-mean distributions." },
};

pub fn isRefuted(name: []const u8) ?[]const u8 {
    for (refutations) |r| {
        if (std.mem.eql(u8, r.claim, name)) return r.reason;
    }
    return null;
}

pub fn isConfirmed(name: []const u8) bool {
    // A confirmed claim is a manifest line of the form `"<name>": true`.
    // Meta objects (_meta, _refuted) carry string values, never `true`.
    var buf: [256]u8 = undefined;
    const needle = std.fmt.bufPrint(&buf, "\"{s}\": true", .{name}) catch return false;
    return std.mem.indexOf(u8, manifest_json, needle) != null;
}

fn printRefuted() void {
    std.debug.print("\n=== Formally Refuted Claims ({d}) ===\n\n", .{refutations.len});
    for (refutations, 1..) |r, i| {
        std.debug.print("{d}. {s}\n   {s}\n\n", .{ i, r.claim, r.reason });
    }
    std.debug.print("Source: Lean 4 / Mathlib (2026-06-27 through 2026-07-01)\n\n", .{});
}

fn checkClaim(name: []const u8) void {
    if (isRefuted(name)) |reason| {
        std.debug.print("REFUTED: {s}\n{s}\n", .{ name, reason });
        return;
    }
    if (isConfirmed(name)) {
        std.debug.print("CONFIRMED: {s}\n  Formally proved in Lean 4 / Mathlib.\n", .{name});
        return;
    }
    std.debug.print("UNKNOWN/PENDING: {s}\n  Not confirmed in proof_manifest.json.\n", .{name});
}

pub fn main(init: std.process.Init) !void {
    var iter = try std.process.Args.Iterator.initAllocator(init.minimal.args, init.gpa);
    defer iter.deinit();
    _ = iter.next(); // program name

    const cmd = iter.next() orelse {
        std.debug.print(
            "formal-counterex — formally verified refutation database\n\n" ++
            "Commands:\n" ++
            "  list-refuted         Show all 7 formally refuted claims\n" ++
            "  check <claim>        Check claim status in manifest\n", .{});
        return;
    };

    if (std.mem.eql(u8, cmd, "list-refuted")) {
        printRefuted();
    } else if (std.mem.eql(u8, cmd, "check")) {
        if (iter.next()) |claim| {
            checkClaim(claim);
        } else {
            std.debug.print("Usage: check <claim>\n", .{});
        }
    } else {
        std.debug.print("Unknown command: {s}\n", .{cmd});
    }
}

test "refutations count is 7" {
    try std.testing.expectEqual(@as(usize, 7), refutations.len);
}

test "cvar_is_coherent is refuted" {
    const r = isRefuted("cvar_is_coherent");
    try std.testing.expect(r != null);
    try std.testing.expect(std.mem.containsAtLeast(u8, r.?, 1, "REFUTED"));
}

test "non-refuted claim returns null" {
    try std.testing.expect(isRefuted("es_is_coherent") == null);
}

test "kelly_maximizes_expected_wealth is refuted" {
    const r = isRefuted("kelly_maximizes_expected_wealth");
    try std.testing.expect(r != null);
}

test "all 7 claims are in the refutation list" {
    const expected = [_][]const u8{
        "cvar_is_coherent", "sharpe_scale_invariant_all_c",
        "diversification_always_reduces_variance", "kelly_maximizes_expected_wealth",
        "max_sharpe_always_equal_weights", "all_martingales_bounded", "es_symmetric_in_alpha",
    };
    for (expected) |name| {
        try std.testing.expect(isRefuted(name) != null);
    }
}
