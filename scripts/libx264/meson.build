# https://mesonbuild.com/External-Project-module.html

project('libx264', 'c')

mod = import('unstable-external_project')

c_args = get_option('c_args')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        '--disable-cli'
    ],
    env: {
        'ASFLAGS': host_machine.cpu() == 'amd64' ? '' : ' '.join(c_args)
    },
    verbose: true,
)

libx264_dep = p.dependency('libx264')
meson.override_dependency('libx264', libx264_dep)
