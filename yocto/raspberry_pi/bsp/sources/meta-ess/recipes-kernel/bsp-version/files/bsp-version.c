/*
    description:
        exposes build version and git info in /proc/build_version

    build:
        petalinux-build -c build-version
        results at build/tmp/sysroots-components/xilinx_zcu104/build-version/lib/modules/5.15.19-xilinx-v2022.1/extra/build-version.ko
    test:
        scp build/tmp/sysroots-components/xilinx_zcu104/build-version/lib/modules/5.15.19-xilinx-v2022.1/extra/build-version.ko root@<ip>:/dev/shm
        chmod a+x /dev/shm/build-version.ko
        insmod /dev/shm/build-version.ko
        cat /proc/build_version
 */

#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

#include "version.h"

#define VERSION_PROC_NAME "build_version"

static struct proc_dir_entry *entry;

static int build_version_show(struct seq_file *m, void *v)
{
  seq_printf(m, VERSION);
  return 0;
}

static int build_version_open(struct inode *inode, struct  file *file)
{
  return single_open(file, build_version_show, NULL);
}

static const struct proc_ops proc_file_fops = {
  .proc_open = build_version_open,
  .proc_read = seq_read,
  .proc_lseek = seq_lseek,
  .proc_release = single_release,
};

static int build_version_init(void)
{
    pr_info("build version: %s", VERSION);

    entry = proc_create(VERSION_PROC_NAME, 0, NULL, &proc_file_fops);
    if(entry == NULL) {
        pr_info("version_init proc_create() failure");
        return -ENOMEM;
    }

	return 0;
}

static void build_version_cleanup(void)
{
	proc_remove(entry);
}

module_init(build_version_init);
module_exit(build_version_cleanup);

MODULE_LICENSE("GPL");
MODULE_INFO(intree, "Y");