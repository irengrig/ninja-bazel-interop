load("@ninja_bazel_interop//:rules_ninja.bzl", "ninja_configuration", "ninja_target")

ninja_configuration(
    name = "configuration",
    build_ninja = ":build.ninja",
    root_marker_file = ":build.ninja",
)

ninja_target(
    name = "fun_a",
    srcs = ["fun_a.cxx", "fun_a.h"],
    ninja_configuration = ":configuration",
    outputs = [
        "lib/fun_a.a",
    ],
    target = "lib/fun_a.a",
)

filegroup(
    name = "fun_a_srcs",
    output_group = "fun_a.a",
    srcs = [":fun_a"]
)

cc_import(
    name = "import_a",
    hdrs = ["fun_a.h"],
    static_library = ":fun_a_srcs"
)

cc_library(
    name = "fun_b",
    hdrs = ["fun_b.h"],
    srcs = ["fun_b.cxx"],
    deps = [":import_a"],
)

ninja_target(
    name = "fun_c",
    srcs = ["fun_c.cxx", "fun_c.h", "fun_a.h", "fun_b.h"],
    ninja_configuration = ":configuration",
    outputs = ["lib/fun_c.a"],
    target = "lib/fun_c.a",
)

filegroup(
    name = "fun_c_srcs",
    output_group = "fun_c.a",
    srcs = [":fun_c"]
)

cc_import(
    name = "import_c",
    hdrs = ["fun_c.h"],
    static_library = ":fun_c_srcs"
)

cc_binary(
    name = "call_from_bazel",
    srcs = ["call_fun_c.cxx"],
    deps = [":import_a", ":import_c", ":fun_b"]
)

ninja_target(
    name = "call_from_ninja",
    srcs = ["call_fun_c.cxx", "fun_c.h", "fun_a.h", "fun_b.h", "fun_a.cxx", "fun_c.cxx"],
    symlink_flat = [":fun_b"],
    ninja_configuration = ":configuration",
    outputs = ["out/hello"],
    target = "out/hello"
)
