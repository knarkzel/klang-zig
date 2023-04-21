const std = @import("std");
const Token = @import("Lexer.zig").Token;
const ArrayList = std.ArrayList;
const Self = @This();

index: usize,
input: []Token,
allocator: std.mem.Allocator,

pub const Value = union(enum) {
    number: usize,
    literal: []const u8,
    statement: struct {
        left: []const u8,
        right: *Value,
    },
};

pub fn init(alloc: std.mem.Allocator, tokens: []Token) Self {
    return .{
        .index = 0,
        .input = tokens,
        .allocator = alloc,
    };
}

fn number(self: *Self) !?Value {
    const token = self.input[self.index];
    if (token.kind == .number) {
        const integer = try std.fmt.parseInt(usize, token.slice, 10);
        self.index += 1;
        return Value{
            .number = integer,
        };
    }
    return null;
}

fn literal(self: *Self) ![]const u8 {
    const token = self.input[self.index];
    if (token.kind == .literal) {
        self.index += 1;
        return token.slice;
    }
    return null;
}

fn assignment(self: *Self) !?Value {
    const left = try self.literal();
    const token = self.input[self.index];
    if (token.kind == .assign) {
        self.index += 1;
    } else return null;
    const right = try self.number() orelse return null;
    return Value{
        .statement = .{
            .left = left,
            .right = try self.allocator.create(right),
        },
    };
}

pub fn next(self: *Self) !?Value {
    // Early return if empty
    if (self.index >= self.input.len) return null;

    // Parsers
    const parsers = .{number};

    inline for (parsers) |parser| {
        if (try parser(self)) |value| return value;
    } else return null;
}
