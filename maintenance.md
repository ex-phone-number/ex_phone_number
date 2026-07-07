# Maintenance

This document outlines the maintenance procedures for the ExPhoneNumber library.

## Update metadata

- `mix update_metadata`
- update [CHANGELOG.md](CHANGELOG.md)
- commit as "Update metadata to <libphonenumber version>"

## Release

- update [CHANGELOG.md](CHANGELOG.md)
  - Update [Unreleased] to [x.x.x]
  - Add new link at the bottom
- update $VERSION in [mix.exs](mix.exs)
- update &VERSION in [README.md](README.md)
- `export VERSION=x.x.x`
- `git commit -am "Release v$VERSION"`
- `git tag v$VERSION`
- `git push origin master --tags`
- `mix hex.publish`
  - [See docs](https://hex.pm/docs/publish)
  - It is doing:
    - `mix publish package`
    - `mix hex.publish docs`
      - Can be tested manually with `mix docs`
- Check [Hex.pm](https://hex.pm/packages/ex_phone_number)
- Add new release in [Github Releases](https://github.com/ex-phone-number/ex_phone_number/releases)

## Add owner in Hex

`mix hex.owner add ex_phone_number <email or hex.pm username> --level maintainer`
