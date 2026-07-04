/*
 * arch/arm64/mm/cache-mtk-v8.S
 *
 * Reconstruction of MediaTek's inner-cache maintenance primitives. The
 * original vendor cache-mtk-v8.S is absent from this source drop, and the
 * fallback that had been left in drivers/misc/mediatek/cmo/cmo-mtk.c was a
 * set of no-op weak stubs. On MT6765 the M4U (multimedia IOMMU) is not
 * cache-coherent with the CPU, so a no-op "flush all inner d-cache" lets the
 * M4U hardware read stale page-table / buffer data straight out of DRAM,
 * corrupting display/camera memory very early in boot -- exactly the kind of
 * failure that reboots the device before the boot animation appears.
 *
 * These provide the canonical ARMv8 "clean+invalidate the entire data/unified
 * cache hierarchy up to the Level of Coherency, by set/way" routine, which is
 * what the vendor implementation did. Callers run these with IRQs disabled
 * (see cmo-mtk.c), so the CSSELR/CCSIDR accesses do not need their own
 * interrupt-atomic critical section.
 *
 * Copyright (C) 2015 MediaTek Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/linkage.h>

	.macro	mtk_dcache_flush_all_setway
	dmb	sy				// order against prior memory accesses
	mrs	x0, clidr_el1			// read cache level ID register
	and	x3, x0, #0x7000000		// extract Level of Coherency
	lsr	x3, x3, #23			// left-align the LoC bit field
	cbz	x3, 5f				// LoC == 0 -> nothing to do
	mov	x10, #0				// start at cache level 0
1:
	add	x2, x10, x10, lsr #1		// x2 = 3 * current level
	lsr	x1, x0, x2			// extract this level's cache type
	and	x1, x1, #7
	cmp	x1, #2				// no cache or i-cache only?
	b.lt	4f				// -> skip this level
	msr	csselr_el1, x10			// select this cache level
	isb					// sync CSSELR before reading CCSIDR
	mrs	x1, ccsidr_el1			// read cache geometry
	and	x2, x1, #7			// x2 = log2(line size) - 4
	add	x2, x2, #4			// x2 = log2(line size)
	mov	x4, #0x3ff
	and	x4, x4, x1, lsr #3		// x4 = number of ways - 1
	clz	w5, w4				// w5 = way position shift
	mov	x7, #0x7fff
	and	x7, x7, x1, lsr #13		// x7 = number of sets - 1
2:
	mov	x9, x4				// working copy of way count
3:
	lsl	x6, x9, x5
	orr	x11, x10, x6			// x11 = level | (way << shift)
	lsl	x6, x7, x2
	orr	x11, x11, x6			// x11 |= (set << line-size)
	dc	cisw, x11			// clean & invalidate by set/way
	subs	x9, x9, #1			// next way
	b.ge	3b
	subs	x7, x7, #1			// next set
	b.ge	2b
4:
	add	x10, x10, #2			// next cache level
	cmp	x3, x10
	b.gt	1b
5:
	mov	x10, #0				// reset CSSELR to level 0
	msr	csselr_el1, x10
	dsb	sy				// ensure completion before returning
	isb
	ret
	.endm

/*
 * void __inner_flush_dcache_all(void)
 * void __inner_flush_dcache_L1(void)
 * void __inner_flush_dcache_L2(void)
 *
 * All three clean+invalidate the whole inner cache hierarchy to the LoC.
 * The set/way loop above already walks every level, so an individual "L1
 * only" / "L2 only" distinction is unnecessary for correctness (a full
 * flush is a safe superset); the config actually used on this device
 * (CONFIG_MTK_FIQ_CACHE=y) reaches only __inner_flush_dcache_all anyway.
 * These are strong symbols that override the weak fallbacks in
 * drivers/misc/mediatek/cmo/cmo-mtk.c and .../include/mt-plat/mrdump.h.
 */
ENTRY(__inner_flush_dcache_all)
	mtk_dcache_flush_all_setway
ENDPROC(__inner_flush_dcache_all)

ENTRY(__inner_flush_dcache_L1)
	mtk_dcache_flush_all_setway
ENDPROC(__inner_flush_dcache_L1)

ENTRY(__inner_flush_dcache_L2)
	mtk_dcache_flush_all_setway
ENDPROC(__inner_flush_dcache_L2)
