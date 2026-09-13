# Agent Development Guide

A file for [guiding coding agents](https://agents.md/).

## Commands

- **Checking:** `nix flake check`
- **Formatting:** `nix fmt`

## Directory Structure

- local development configuration: `.config/`
- readme assets: `assets/`
- app crates: `crates/`
- widget crates: `crates/ghost-shell-widgets/`

## Project

`blazing-cluster` is the NixOS configuration for a cluster of Compute Blade
nodes built around Raspberry Pi Compute Modules.

Primary repository:

https://github.com/thatwhichisdev/blazing-cluster

This project is actively developed. **Always inspect the current repository
state before making assumptions about the configuration, hosts, modules,
packages, or recent changes.** Prefer the checked-out source tree and its
`flake.lock` over remembered context, old conversations, documentation snippets,
or assumptions.

When external verification is needed, check the current `master` branch of the
repository above.

## Related Repositories

### Blazing Fan

Compute Blade Smart Fan Unit hardware-facing software and firmware live in a
separate project:

https://github.com/thatwhichisdev/blazing-fan

`blazing-fan` contains the fan firmware and supporting software and is primarily
written in Rust. `blazing-cluster` consumes it as an external flake input.

When a task concerns fan control, fan firmware, its protocol, daemon, TUI, or
Smart Fan Unit behavior, inspect `blazing-fan` rather than reimplementing that
logic inside `blazing-cluster`.

### NixOS Raspberry Pi

The Raspberry Pi / Compute Module foundation is based on:

https://github.com/nvmd/nixos-raspberrypi

The project tracks the **NixOS 26.05** release line.

When investigating Raspberry Pi boot, kernel, firmware, device-tree, installer,
page-size, or board-specific behavior:

1. Check the exact `nixos-raspberrypi` revision pinned by `flake.lock`.
2. Consult the corresponding `nixos-26.05` upstream code.
3. Prefer upstream-supported mechanisms over local workarounds.
4. Do not assume behavior from upstream `develop` or a newer release applies to
   this project.

## Engineering Priorities

The cluster runs on small, efficient Compute Blade nodes. Optimize software
accordingly.

Priorities, in order:

1. Correctness and reliability.
2. Low runtime overhead.
3. Low CPU usage and unnecessary wakeups.
4. Low memory usage.
5. Minimal disk and network I/O.
6. Fast startup and simple operation.
7. Maintainability and clear configuration.

Avoid heavyweight services, runtimes, abstractions, and dependency trees when a
simpler solution provides the same functionality.

Measure performance-sensitive changes when practical instead of assuming that an
implementation is efficient.

## Language and Implementation Preferences

For custom software, **prefer Rust** unless another language or existing
implementation is clearly better suited to the task.

Rust is especially preferred for:

- long-running daemons;
- hardware-facing services;
- system utilities;
- networking services;
- monitoring and telemetry components;
- performance-sensitive tools.

Do not rewrite mature upstream software in Rust merely for language consistency.
Reuse good existing software when it is more reliable and efficient.

Prefer software already packaged by `nixpkgs` when it satisfies the
requirements. Add or maintain a local package only when there is a concrete
reason to do so.

## NixOS Principles

Keep the system declarative and reproducible.

Prefer:

- NixOS modules over imperative setup;
- systemd units managed through NixOS;
- packages from `nixpkgs`;
- flake inputs for external projects;
- explicit host configuration;
- secrets managed through the repository's existing secret-management approach;
- small reusable modules instead of duplicated host configuration.

Do not introduce ad-hoc installation scripts, mutable `/etc` configuration,
manually installed binaries, or runtime package managers unless there is no
reasonable declarative alternative.

Follow the repository's existing structure and style before inventing a new
abstraction.

## Working With the Repository

Before changing anything:

1. Inspect `git status` and the relevant recent history.
2. Read `flake.nix` and `flake.lock` when dependencies or platform behavior
   matter.
3. Inspect the relevant host under `hosts/`.
4. Inspect existing modules under `modules/` before creating a new one.
5. Inspect `pkgs/` before adding package definitions.
6. Search the repository for an existing implementation or convention.

Do not assume that host names, hardware generations, enabled services, or module
interfaces described in this file are exhaustive. The repository itself is
authoritative.

Keep changes focused. Avoid unrelated refactors unless they are necessary for
the requested change.

## Hardware Awareness

The target platform is Compute Blade hardware using Raspberry Pi Compute
Modules, including CM4 and CM5 systems.

Hardware behavior can vary between Compute Module revisions, carrier boards,
peripherals, and firmware versions. When debugging hardware:

- verify the exact target host and module model;
- inspect kernel logs with tools such as `dmesg`;
- confirm device enumeration rather than assuming a peripheral is present;
- distinguish hardware failure from NixOS configuration failure;
- compare against another known-good blade or module when possible.

For CM-specific boot, kernel, firmware, PCIe/NVMe, device-tree, or peripheral
issues, check the pinned `nixos-raspberrypi` implementation before applying
generic Raspberry Pi advice.

## Validation

Use the narrowest useful validation first, then broaden it when needed.
