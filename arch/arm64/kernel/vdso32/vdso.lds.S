/*
 * Adapted from arm64 version.
 *
 * GNU linker script for the VDSO library.
 *
 * Copyright (C) 2012 ARM Limited
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Will Deacon <will.deacon at arm.com>
 * Heavily based on the vDSO linker scripts for other archs.
 */

#include <linux/const.h>
#include <asm/page.h>
#include <asm/vdso.h>

OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

SECTIONS
{
	PROVIDE_HIDDEN(_vdso_data = . - PAGE_SIZE);
	. = VDSO_LBASE + SIZEOF_HEADERS;

	.hash		: { *(.hash) }			:text
	.gnu.hash	: { *(.gnu.hash) }
	.dynsym		: { *(.dynsym) }
	.dynstr		: { *(.dynstr) }
	.gnu.version	: { *(.gnu.version) }
	.gnu.version_d	: { *(.gnu.version_d) }
	.gnu.version_r	: { *(.gnu.version_r) }

	.note		: { *(.note.*) }		:text	:note

	.dynamic	: { *(.dynamic) }		:text	:dynamic

	.rodata		: { *(.rodata*) }		:text

	.text		: { *(.text*) }			:text	=0xe7f001f2

	.got		: { *(.got) }
	.rel.plt	: { *(.rel.plt) }

	/DISCARD/	: {
		*(.note.GNU-stack)
		*(.data .data.* .gnu.linkonce.d.* .sdata*)
		*(.bss .sbss .dynbss .dynsbss)
	}
}

/*
 * We must supply the ELF program headers explicitly to get just one
 * PT_LOAD segment, and set the flags explicitly to make segments read-only.
 */
PHDRS
{
	text		PT_LOAD		FLAGS(5) FILEHDR PHDRS; /* PF_R|PF_X */
	dynamic		PT_DYNAMIC	FLAGS(4);		/* PF_R */
	note		PT_NOTE		FLAGS(4);		/* PF_R */
}

VERSION
{
	LINUX_2.6 {
	global:
		__vdso_clock_gettime;
		__vdso_gettimeofday;
		__kernel_sigreturn_arm;
		__kernel_sigreturn_thumb;
		__kernel_rt_sigreturn_arm;
		__kernel_rt_sigreturn_thumb;
	local: *;
	};
}

/*
 * Make the sigreturn code visible to the kernel.
 */
VDSO_compat_sigreturn_arm	= __kernel_sigreturn_arm;
VDSO_compat_sigreturn_thumb	= __kernel_sigreturn_thumb;
VDSO_compat_rt_sigreturn_arm	= __kernel_rt_sigreturn_arm;
VDSO_compat_rt_sigreturn_thumb	= __kernel_rt_sigreturn_thumb;
