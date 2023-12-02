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
    const std_in = std.io.getStdIn().reader();
    const stderr = std.io.getStdErr().writer();
    var buffer: [4096]u8 = undefined;
    var out_buf: [4096]u8 = undefined;
    while (true) {
        var read = try std_in.read(&buffer);
        if (read < 1) {
            break;
        }
        const size = base64.encode_no_pad(buffer[0..read], out_buf[0..]);
        if (stdout.write(out_buf[0..size])) |_| {} else |err| {
            try stderr.print("err {}", .{err});
        }
    }
    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test {
    @import("std").testing.refAllDecls(@This());
}
