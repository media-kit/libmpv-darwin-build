# https://mesonbuild.com/External-Project-module.html

project('libx264', 'c')

mod = import('unstable-external_project')

cross_prefix = meson.get_cross_property('cross_prefix')
if not cross_prefix.endswith('/')
  cross_prefix += '/'
endif

c_args = get_option('c_args')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--cross-prefix=@0@'.format(cross_prefix),
        '--enable-shared',
        '--disable-cli',
    ],
    env: {
        'ASFLAGS': host_machine.cpu() == 'amd64' ? '' : ' '.join(c_args)
    },
    verbose: true,
)

libx264_dep = p.dependency('libx264')
meson.override_dependency('libx264', libx264_dep)
