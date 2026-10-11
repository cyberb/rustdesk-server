local name = 'rustdesk-server';

local rust = '1-bookworm';
local debian = 'bookworm-slim';

local build(arch, target, image, test) = {
  kind: 'pipeline',
  type: 'docker',
  name: arch,
  platform: {
    os: 'linux',
    arch: 'amd64',
  },
  steps: [
    {
      name: 'submodules',
      image: 'rust:' + rust,
      commands: ['git submodule update --init --recursive'],
    },
  ] + (if test then [
            {
              name: 'test',
              image: 'rust:' + rust,
              commands: ['./ci/unit.sh'],
            },
          ] else []) + [
    {
      name: 'build',
      image: image,
      commands: ['./ci/build.sh ' + target + ' ' + arch],
    },
    {
      name: 'package',
      image: 'debian:' + debian,
      commands: ['./ci/package.sh ' + arch],
    },
    {
      name: 'artifact',
      image: 'appleboy/drone-scp:1.6.4',
      settings: {
        host: { from_secret: 'artifact_host' },
        username: 'artifact',
        key: { from_secret: 'artifact_key' },
        timeout: '2m',
        command_timeout: '2m',
        target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}',
        source: ['artifact/*.zip'],
        strip_components: 1,
      },
    },
    {
      name: 'publish to github',
      image: 'plugins/github-release:1.0.0',
      settings: {
        api_key: { from_secret: 'github_token' },
        files: 'artifact/*.zip',
        prerelease: true,
        overwrite: true,
        file_exists: 'overwrite',
      },
      when: {
        event: ['tag'],
      },
    },
  ],
  trigger: {
    event: ['push', 'tag'],
  },
};

[
  build('amd64', 'x86_64-unknown-linux-musl', 'messense/rust-musl-cross:x86_64-musl', true),
  build('arm64v8', 'aarch64-unknown-linux-musl', 'messense/rust-musl-cross:aarch64-musl', false),
  build('armv7', 'armv7-unknown-linux-musleabihf', 'messense/rust-musl-cross:armv7-musleabihf', false),
]
