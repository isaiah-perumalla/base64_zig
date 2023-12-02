const std = @import("std");
pub const standard_alphabet_chars: *const [64:0]u8 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
pub const chars = standard_alphabet_chars;

pub fn encode(in: []const u8, out: []u8) usize {
    const mask = 0x3F; // mask 2^6 -1, extract lower 6 bits
    var i: usize = 0;
    var out_idx: usize = 0;
    while (i + 2 < in.len) : (i += 3) {
        const b0 = in[i];
        const b1 = in[i + 1];
        const b2 = in[i + 2];
        const c0 = b0 >> 2;
        const c1 = ((b0 << 4) & mask) | (b1 >> 4);
        const c2 = ((b1 << 2) & mask) | (b2 >> 6);
        const c3 = (b2 & mask);

        out[out_idx] = chars[c0];
        out[out_idx + 1] = chars[c1];
        out[out_idx + 2] = chars[c2];
        out[out_idx + 3] = chars[c3];
        out_idx += 4;
    }
    return out_idx;
}

test "simple encode" {
    // std.base64.Base64Encoder.encode(encoder: *const Base64Encoder, dest: []u8, source: []const u8)
    const input = "isaiah__p";
    const expected: [12]u8 = "aXNhaWFoX19w".*;
    var out_buffer: [32]u8 = undefined;
    const size = encode(input, out_buffer[0..]);
    const actual = out_buffer[0..size];
    try std.testing.expectEqualSlices(u8, expected[0..], actual);
}
