load("@ninja_bazel_interop//:rules_ninja.bzl", "ninja_configuration", "ninja_target")

ninja_configuration(
    name = "configuration",
    build_ninja = ":build.ninja",
    root_marker_file = ":build.ninja",
)

ninja_target(
    name = "ninja_default_target",
    srcs = ["hello.cxx"],
    ninja_configuration = ":configuration",
    outputs = [
        "out/hello",
        "out/hello.o",
    ],
    target = "out/hello",
)
