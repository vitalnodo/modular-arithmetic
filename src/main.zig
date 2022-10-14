const std = @import("std");
const testing = std.testing;
const mod = std.math.mod;
const rem = std.math.rem;
const math_pow = std.math.pow;
const divTrunc = std.math.divTrunc;

pub fn ModularArithmetic(comptime T: type) type {
    return struct {
        a: T,
        m: T,
        const Self = @This();

        pub fn init(a: T, m: T, args: anytype) !Self {
            var res: T = 0;
            if (args.allowNegative) {
                res = try rem(T, a, m);
            } else {
                res = try mod(T, a, m);
            }
            return Self{ .a = res, .m = m };
        }

        pub fn initPositive(a: T, m: T) !Self {
            return Self.init(a, m, .{ .allowNegative = false });
        }

        pub fn initNegative(a: T, m: T) !Self {
            return Self.init(a, m, .{ .allowNegative = true });
        }

        pub fn pow(self: Self, exponent: T) !Self {
            if (exponent == 0) {
                return Self{ .a = 1, .m = self.m };
            }
            if (exponent > 0) {
                return try self.powPositive(exponent);
            } else {
                // var n = try self.inverse();
                // return try n.powPositive(exponent);
                return error.NegativeExponentiationNotWorks;
            }
        }

        fn powPositive(self: Self, exponent: T) !Self {
            var exp = exponent;
            var digit = try rem(T, exp, 2);
            var d = try rem(T, digit * self.a, self.m);
            var t = try rem(T, math_pow(T, d, 2), self.m);
            while (exp > 0) {
                exp = try divTrunc(T, exp, 2);
                digit = try rem(T, exp, 2);
                if (digit == 1) d = try rem(T, digit * (d * t), self.m);
                t = try rem(T, math_pow(T, t, 2), self.m);
            }
            return Self.initPositive(d, self.m);
        }

        fn inverse(self: Self) !Self {
            return solveCongruence(self.a, 1, self.m);
        }

        /// a*x ≡ b mod m
        /// many or zero solutions currently not implemented
        pub fn solveCongruence(a: T, b: T, m: T) !Self {
            if (utils.gcd(T, a, m) == 1) {
                var n = try Self.initPositive(a, m);
                n = try Self.powPositive(n, utils.euler(T, m) - 1);
                return Self.initPositive(b * n.a, m);
            } else {
                return error.ManyOrZeroSolutions;
            }
        }
    };
}

pub const utils = struct {
    pub fn gcd(comptime T: type, a: T, b: T) T {
        if (a == 0) {
            return b;
        }
        var _a = a;
        var _b = b;
        while (_b != 0) {
            if (_a > _b) {
                _a = _a - _b;
            } else {
                _b = _b - _a;
            }
        }
        return _a;
    }

    pub fn euler(comptime T: type, n: T) T {
        var i: usize = 0;
        var result: T = 0;
        while (i < n) : (i += 1) {
            if (gcd(T, @intCast(T, i), n) == 1) {
                result += 1;
            }
        }
        return result;
    }
};

test "basic" {
    const Mod = ModularArithmetic(i16);
    var n = try Mod.initPositive(43, 42);
    try testing.expect(n.a == 1);
    n = try Mod.initPositive(-24, 18);
    try testing.expect(n.a == 12);
    n = try Mod.initNegative(-24, 18);
    try testing.expect(n.a == -6);
}

test "utils" {
    try testing.expect(utils.gcd(u16, 24, 20) == 4);
    try testing.expect(utils.gcd(u16, 39, 27) == 3);
    try testing.expect(utils.gcd(u16, 64, 27) == 1);
    try testing.expect(utils.gcd(u16, 124, 36) == 4);

    try testing.expect(utils.euler(u16, 10) == 4);
    try testing.expect(utils.euler(u16, 36) == 12);
    try testing.expect(utils.euler(u16, 1024) == 512);
}

test "power" {
    const Mod = ModularArithmetic(i32);
    var n = try Mod.initPositive(175, 257);
    try testing.expect((try n.pow(235)).a == 3);
    n = try Mod.initPositive(707, 17);
    try testing.expect((try n.pow(321)).a == 10);
    n = try Mod.initPositive(2, 7);
    try testing.expectError(error.NegativeExponentiationNotWorks, n.pow(-5));
}

test "linear congruence" {
    const Mod = ModularArithmetic(usize);
    try testing.expect((try Mod.solveCongruence(13, 2, 53)).a == 45);
    try testing.expect((try Mod.solveCongruence(16, 50, 23)).a == 6);
    try testing.expect((try Mod.solveCongruence(32, 182, 119)).a == 28);
}

test "inverse" {
    const Mod = ModularArithmetic(u16);
    var n = try Mod.initPositive(2, 5);
    try testing.expect((try n.inverse()).a == 3);
    n = try Mod.initPositive(47, 82);
    try testing.expect((try n.inverse()).a == 7);
    n = try Mod.initPositive(48, 82);
    try testing.expectError(error.ManyOrZeroSolutions, n.inverse());
}
