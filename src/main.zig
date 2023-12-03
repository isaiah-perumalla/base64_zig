const std = @import("std");
const base64 = @import("base64.zig");
const BUFFER_SIZE: usize = 4096 * 4;

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
    var buffer: [BUFFER_SIZE]u8 = undefined;
    var out_buf: [BUFFER_SIZE * 2]u8 = undefined;
    var prefix: usize = 0;
    while (true) {
        const read = try std_in.read(buffer[prefix..]);

        if (read < 1) {
            break;
        }

        const result = base64.encode_no_pad(buffer[0..read], out_buf[0..]);
        const encoded_size = result.encoded_size;
        if (stdout.write(out_buf[0..encoded_size])) |_| {} else |err| {
            try stderr.print("err {}", .{err});
        }
        if (result.rem_size > 0) {
            const rem = result.rem_size;
            var i: usize = 0;
            while (i < rem) : (i += 1) {
                buffer[i] = result.rem[i];
            }
            prefix = rem;
        }
    }
    if (prefix == 1) {
        base64.encode_pad(buffer[0], null, out_buf[0..]);
        _ = try stdout.write(out_buf[0..4]);
    } else if (prefix == 2) {
        base64.encode_pad(buffer[0], buffer[1], out_buf[0..]);
        _ = try stdout.write(out_buf[0..4]);
    } else if (prefix != 0) {
        unreachable; //cannot be > 2
    }
    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test {
    @import("std").testing.refAllDecls(@This());
}
