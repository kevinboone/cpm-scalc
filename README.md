# cpm-scalc

A simple, very small programmer's calculator for CP/M (Z80).

Version 0.1b, June 2023 

This utility is designed to be built using the Microft assembler and linker,
M80.COM and L80.COM. There is a Makefile for building under Linux.  `scalc.sub`
is for building on CP/M. This will likely need to be edited if the assembler
and linker aren't on the same disk as the source files. The resulting binary
should be smaller than 2kB.

`SCALC.TXT` contains brief instructions, and is intended to be distributed with
the binary `scalc.com`.

`GRAMMAR.TXT` describes the grammar, along with some implementation details.

`scalc` is maintained by Kevin Boone, and is distributed under the terms of the
GNU public licence, v3.0.

## Revisions

0.1a February 2022
First release

0.1b June 2023
Fixed a bug in handling the command line

