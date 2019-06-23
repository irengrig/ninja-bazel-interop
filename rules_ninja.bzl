NinjaConfiguration = provider(
    doc = "Describes build.ninja file, it's included files and working directory",
    fields = {
        "working_directory": "working directory for invoking ninja",
        "build_ninja": "ninja configuration file",
    },
)

def _impl_ninja_configuration(ctx):
    return [
        NinjaConfiguration(
            working_directory = ctx.file.root_marker_file.dirname,
            build_ninja = ctx.file.build_ninja,
        ),
        DefaultInfo(files = depset(direct = ctx.files.includes + [ctx.file.build_ninja])),
    ]

ninja_configuration = rule(
    implementation = _impl_ninja_configuration,
    attrs = {
        "root_marker_file": attr.label(allow_single_file = True),
        "build_ninja": attr.label(allow_single_file = True),
        "includes": attr.label_list(mandatory = False, allow_files = True),
    },
)

def _impl_ninja_target(ctx):
    ninja_configuration = ctx.attr.ninja_configuration[NinjaConfiguration]
    if not ninja_configuration:
        fail("ninja_configuration should point to ninja_configuration rule target.")

    inputs = ctx.attr.ninja_configuration.files.to_list()
    for l in ctx.attr.srcs:
        inputs += l.files.to_list()
    symlink_flat = []
    for l in ctx.attr.symlink_flat:
        inputs += l.files.to_list()
        symlink_flat += l.files.to_list()
    declared_outputs = []
    script = "echo '' "
    for symlink_flat_file in symlink_flat:
        script += " && ln -s %s %s " % (symlink_flat_file.path, symlink_flat_file.basename)
    script += " && ninja -C %s -f %s %s" % (ninja_configuration.working_directory, ninja_configuration.build_ninja.path, ctx.attr.target)
    for output in ctx.attr.outputs:
        declared = ctx.actions.declare_file(output)
        declared_outputs.append(declared)
        script += " && cp %s %s " % (output, declared.path)

    ctx.actions.run_shell(
        mnemonic = "NinjaTarget",
        inputs = depset(inputs),
        outputs = declared_outputs,
        use_default_shell_env = True,
        # todo later, introduce ninja toolchain
        command = script,
        execution_requirements = {"block-network": ""},
    )

    output_groups = dict()
    for out_file in declared_outputs:
        output_groups[out_file.basename] = [out_file]

    return [
        DefaultInfo(files = depset(direct = declared_outputs)),
        OutputGroupInfo(**output_groups),
    ]

ninja_target = rule(
    implementation = _impl_ninja_target,
    attrs = {
        "ninja_configuration": attr.label(),
        "target": attr.string(),
        "srcs": attr.label_list(allow_files = True),
        "symlink_flat": attr.label_list(allow_files = True, mandatory = False),
        "outputs": attr.string_list(),
    },
)
