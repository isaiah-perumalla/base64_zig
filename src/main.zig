const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("type something on {s}\n", .{"terminal"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const std_in = std.io.getStdIn().reader();
    const stdout = bw.writer();
    const stderr = std.io.getStdErr().writer();
    var buffer = [_]u8{0} ** 4096;
    while (true) {
        var read = try std_in.read(&buffer);
        if (read < 1) {
            break;
        }
        if (stdout.write(buffer[0..read])) |_| {} else |err| {
            try stderr.print("err {}", .{err});
        }
    }
    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
