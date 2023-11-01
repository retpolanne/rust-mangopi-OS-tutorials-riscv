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
	#mrs	a0, MPIDR_EL1
	#and	a0, a0, {CONST_CORE_ID_MASK}
	la	a1, BOOT_CORE_ID      // provided by bsp/__board_name__/cpu.rs
	#cmp	a0, a1
	bne	a0, a1, .L_parking_loop

	// If execution reaches here, it is the boot core.

	// Initialize DRAM.
  la t5, __bss_start
  la t6, __bss_end_exclusive

.L_bss_init_loop:
	beq	a0, a1, .L_prepare_rust
	#stp	xzr, xzr, [a0], #16
	j	.L_bss_init_loop

	// Prepare the jump to Rust code.
.L_prepare_rust:
	// Set the stack pointer.
	la sp, __boot_core_stack_end_exclusive

	// Jump to Rust code.
  la t0, _start_rust
  csrw mepc, t0
	tail	_start_rust

	// Infinitely wait for events (aka "park the core").
.L_parking_loop:
	wfi
	j	.L_parking_loop

.size	_start, . - _start
.type	_start, function
.global	_start
