const std = @import("std");
const ascii = std.ascii;
const Self = @This();

index: usize,
input: []const u8,

pub const Token = struct {
    kind: enum {
        number,
        literal,
        assign,
    },
    slice: []const u8,
};

pub fn init(program: []const u8) Self {
    return .{
        .index = 0,
        .input = program,
    };
}

fn operator(self: *Self) ?Token {
    const single = self.input[self.index .. self.index + 1];
    if (std.mem.eql(u8, "=", single)) {
        self.index += 1;
        return Token{
            .kind = .assign,
            .slice = single,
        };
    } else return null;
}

fn number(self: *Self) ?Token {
    if (ascii.isDigit(self.input[self.index])) {
        var i: usize = self.index;
        while (i < self.input.len and ascii.isDigit(self.input[i])) i += 1;
        defer self.index = i;
        return Token{
            .kind = .number,
            .slice = self.input[self.index..i],
        };
    } else return null;
}

fn literal(self: *Self) ?Token {
    if (ascii.isAlphabetic(self.input[self.index])) {
        var i: usize = self.index;
        while (i < self.input.len and ascii.isAlphabetic(self.input[i])) i += 1;
        defer self.index = i;
        return Token{
            .kind = .literal,
            .slice = self.input[self.index..i],
        };
    } else return null;
}

pub fn next(self: *Self) ?Token {
    // Early return if empty
    if (self.index >= self.input.len) return null;

    // Skip whitespace
    while (self.index < self.input.len and self.input[self.index] == ' ') self.index += 1;

    // Lexers
    const lexers = .{ literal, number, operator };

    inline for (lexers) |lexer| {
        if (lexer(self)) |token| return token;
    } else return null;
}
