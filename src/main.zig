const std = @import("std");
const base64 = @import("base64.zig");
pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    //std.debug.print("type something on {s}\n", .{"terminal"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.

    const stdout_file = std.io.getStdOut().writer();

    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    var out: [16]u8 = undefined;
    try stdout_file.print("{d}", .{base64.encode("isaiah", out[0..])});

    const std_in = std.io.getStdIn().reader();
    const stderr = std.io.getStdErr().writer();
    var buffer: [4096]u8 = undefined;
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

test {
 @import("std").testing.refAllDecls(@This());
}


