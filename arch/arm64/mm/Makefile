obj-y				:= dma-mapping.o extable.o fault.o init.o \
				   cache.o copypage.o flush.o \
				   ioremap.o mmap.o pgd.o mmu.o \
				   context.o proc.o pageattr.o
obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
obj-$(CONFIG_NUMA)		+= numa.o

obj-$(CONFIG_KASAN)		+= kasan_init.o
KASAN_SANITIZE_kasan_init.o	:= n
KBUILD_CPPFLAGS += -Werror -I$(srctree)/drivers/misc/mediatek/include

# cache-mtk-v8.o reconstructs MediaTek's inner-cache maintenance primitives
# (__inner_flush_dcache_all/L1/L2) using the canonical ARMv8 set/way flush.
# The original vendor source was missing from this tree; the no-op weak stubs
# that had covered for it silently disabled M4U cache maintenance, which the
# non-coherent MT6765 M4U hardware needs -- see the file header for details.
obj-$(CONFIG_MEDIATEK_SOLUTION) += cache-mtk-v8.o
