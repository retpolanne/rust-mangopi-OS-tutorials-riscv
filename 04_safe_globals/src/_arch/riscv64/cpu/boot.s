// SPDX-License-Identifier: MIT OR Apache-2.0
//
// Copyright (c) 2021-2022 Andre Richter <andre.o.richter@gmail.com>

//--------------------------------------------------------------------------------------------------
// Definitions
//--------------------------------------------------------------------------------------------------

// Load the address of a symbol into a register, PC-relative.
//
// The symbol must lie within +/- 4 GiB of the Program Counter.
//
// # Resources
//
// - https://sourceware.org/binutils/docs-2.36/as/AArch64_002dRelocations.html

//--------------------------------------------------------------------------------------------------
// Public Code
//--------------------------------------------------------------------------------------------------
.section .text._start

//------------------------------------------------------------------------------
// fn _start()
//------------------------------------------------------------------------------
_start:
	// Only proceed on the boot core. Park it otherwise.
	csrr t0, mhartid
	bnez t0, .L_parking_loop

.option push
.option norelax
.option pop

	// If execution reaches here, it is the boot core.

	// Initialize DRAM.
	la t5, __bss_start
	la t6, __bss_end_exclusive

.L_bss_init_loop:
	sd zero, (t5)
	addi t5, t5, 8
	bltu t5, t6, .L_bss_init_loop
	j	.L_prepare_rust

	// Prepare the jump to Rust code.
.L_prepare_rust:
	// Set the stack pointer.
	la sp, __boot_core_stack_start

	// Jump to Rust code.
	li t0, (0b11 << 11) | (1 << 7) | (1 << 3)
	csrw mstatus, t0
	la t1, _start_rust
	csrw mepc, t1
	mret

	// Infinitely wait for events (aka "park the core").
.L_parking_loop:
	wfi
	j	.L_parking_loop

.size	_start, . - _start
.type	_start, function
.global	_start
