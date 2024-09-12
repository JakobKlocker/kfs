pub fn strlen(str: [*]u8) usize {
    var len: usize = 0;
    while (str[len] != 0) : (len += 1) {}
    return len;
}

//Find solution for this, can't compare .len because one could be 255 (like cmd) yet still smaller
//can't compare null byte because it doesnt exist
pub fn strcmp(s1: []const u8, s2: []const u8) bool {
    var i: usize = 0;

    // if (s1.len != s2.len)
    //     return false;
    while (s1.len < i and s2.len < i) {
        // while (s1[i] != 0 and s1[2] != 0) {
        if (s1[i] != s2[i])
            return false;
        i += 1;
    }
    if (s1[i] != s2[i])
        return false;
    return true;
}
