// SPDX-License-Identifier: MIT OR Apache-2.0
//
// Copyright (c) 2018-2023 Andre Richter <andre.o.richter@gmail.com>

//! Conditional reexporting of Board Support Packages.

#[cfg(any(feature = "bsp_mangopi"))]
mod mangopi;

#[cfg(any(feature = "bsp_mangopi"))]
pub use mangopi::*;
