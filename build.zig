const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.setLinkerScript(b.path("src/linker.ld"));
    exe.addAssemblyFile(b.path("src/boot.s"));
    exe.addAssemblyFile(b.path("src/gdt.s"));

    b.exe_dir = "./"; // set output path
    b.installArtifact(exe);
}
