const std = @import("std");
const Lexer = @import("Lexer.zig");
const Parser = @import("Parser.zig");

// Imports
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    // Lex input
    var lexer = Lexer.init("foo = 100");
    var tokens = ArrayList(Lexer.Token).init(allocator);
    while (lexer.next()) |token| try tokens.append(token);
    for (tokens.items) |token| std.debug.print("{}: {s}\n", .{ token.kind, token.slice });

    // Parse into ast
    var parser = Parser.init(allocator, tokens.items);
    var ast = ArrayList(Parser.Value).init(allocator);
    while (try parser.next()) |value| try ast.append(value);

    // Print ast
    for (ast.items) |value| std.debug.print("{}\n", .{value});
}
