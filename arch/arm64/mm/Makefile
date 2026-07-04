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

# cache-mtk-v8.o intentionally omitted: source file is missing from this
# vendor tree (not present upstream either, and nothing else in-tree
# references its symbols), so it cannot be safely reconstructed. Standard
# arch/arm64/mm/cache.o (restored from upstream v4.9.337) already provides
# the generic cache-maintenance primitives the kernel needs to build/run.
