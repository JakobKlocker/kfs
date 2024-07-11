pub fn strlen(str: [*]u8) usize {
    var len: usize = 0;
    while (str[len] != 0) : (len += 1) {}
    return len;
}

pub fn strcmp(s1: [*]u8, s2: [*]u8) i32 {
    var i: usize = 0;
    while (s1[i] != 0 and s2[i] != 0) : (i += 1) {
        if (s1[i] != s2[i]) {
            return s1[i] - s2[i];
        }
    }
    return s1[i] - s2[i];
}
