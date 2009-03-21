/*
 *	pcimodules:  Load all kernel modules for PCI device currently
 *      plugged into any PCI slot.
 *
 *	Copyright 2000 Yggdrasil Computing, Incorporated
 *	This file may be copied under the terms and conditions of version
 *      two of the GNU General Public License, as published by the Free
 *      Software Foundation (Cambridge, Massachusetts, USA).
 *
 *      This file is based on pciutils/lib/example.c, which has the following
 *      authorship and copyright statement:
 *
 *		Written by Martin Mares and put to public domain. You can do
 *		with it anything you want, but I don't give you any warranty.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <sys/param.h>
#include <sys/types.h>

#define _GNU_SOURCE
#include <getopt.h>

#include "pciutils.h"

#define MODDIR	"/lib/modules"
#define PCIMAP	"modules.pcimap"

#define LINELENGTH	8000

#define DEVICE_ANY	0xffffffff
#define VENDOR_ANY	0xffffffff

#include "lib/pci.h"

struct pcimap_entry {
	unsigned int vendor, subsys_vendor, dev, subsys_dev, class, class_mask;
	char *module;
	struct pcimap_entry *next;
};

static struct pcimap_entry *pcimap_list = NULL;

const char program_name[] = "pcimodules";

#define OPT_STRING "hcm"
static struct option long_options[] = {
	{"class",	required_argument,	NULL, 'c'},
	{"classmask",	required_argument,	NULL, 'm'},
	{"help",	no_argument,		NULL, 'h'},
	{ 0,		0,			0, 	0}
};

static unsigned long desired_class;
static unsigned long desired_classmask; /* Default is 0: accept all classes.*/

static void
read_pcimap(void)
{
	struct utsname utsname;
	char filename[MAXPATHLEN];
	FILE *pcimap_file;
	char line[LINELENGTH];
	struct pcimap_entry *entry;
	unsigned int driver_data;
	char *prevmodule = "";
	char module[LINELENGTH];

	if (uname(&utsname) < 0) {
		perror("uname");
		exit(1);
	}
	sprintf(filename, "%s/%s/%s", MODDIR, utsname.release, PCIMAP);
	if ((pcimap_file = fopen(filename, "r")) == NULL) {
		perror(filename);
		exit(1);
	}

	while(fgets(line, LINELENGTH, pcimap_file) != NULL) {
		if (line[0] == '#')
			continue;

		entry = xmalloc(sizeof(struct pcimap_entry));

		if (sscanf(line, "%s 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x",
			   module,
			   &entry->vendor, &entry->dev,
			   &entry->subsys_vendor, &entry->subsys_dev,
			   &entry->class, &entry->class_mask,
			   &driver_data) != 8) {
			fprintf (stderr,
				"modules.pcimap unparsable line: %s.\n", line);
			free(entry);
			continue;
		}

		/* Optimize memory allocation a bit, in case someday we
		   have Linux systems with ~100,000 modules.  It also
		   allows us to just compare pointers to avoid trying
		   to load a module twice. */
		if (strcmp(module, prevmodule) != 0) {
			prevmodule = xmalloc(strlen(module)+1);
			strcpy(prevmodule, module);
		}
		entry->module = prevmodule;
		entry->next = pcimap_list;
		pcimap_list = entry;
	}
	fclose(pcimap_file);
}

/* Return a filled in pci_access->dev tree, with the device classes
   stored in dev->aux.
*/
static void
match_pci_modules(void)
{
	struct pci_access *pacc;
	struct pci_dev *dev;
	unsigned int class, subsys_dev, subsys_vendor;
	struct pcimap_entry *map;
	const char *prevmodule = "";

	pacc = pci_alloc();		/* Get the pci_access structure */
	/* Set all options you want -- here we stick with the defaults */
	pci_init(pacc);		/* Initialize the PCI library */
	pci_scan_bus(pacc);	/* We want to get the list of devices */
  	for(dev=pacc->devices; dev; dev=dev->next) {
		pci_fill_info(dev, PCI_FILL_IDENT | PCI_FILL_BASES);
		class = (pci_read_word(dev, PCI_CLASS_DEVICE) << 8)
			| pci_read_byte(dev, PCI_CLASS_PROG);
		subsys_dev = pci_read_word(dev, PCI_SUBSYSTEM_ID);
		subsys_vendor = pci_read_word(dev,PCI_SUBSYSTEM_VENDOR_ID);
		for(map = pcimap_list; map != NULL; map = map->next) {
			if (((map->class ^ class) & map->class_mask) == 0 &&
			    ((desired_class ^ class) & desired_classmask)==0 &&
			    (map->dev == DEVICE_ANY ||
			     map->dev == dev->device_id) &&
			    (map->vendor == VENDOR_ANY ||
			     map->vendor == dev->vendor_id) &&
			    (map->subsys_dev == DEVICE_ANY ||
			     map->subsys_dev == subsys_dev) &&
			    (map->subsys_vendor == VENDOR_ANY ||
			     map->subsys_vendor == subsys_vendor) &&
			    prevmodule != map->module) {
				printf("%s\n", map->module);
				prevmodule = map->module;
			}
		}

	}
	pci_cleanup(pacc);
}

int
main (int argc, char **argv)
{
	int opt_index = 0;
	int opt;

	while ((opt = getopt_long(argc, argv, OPT_STRING, long_options,
		           &opt_index)) != -1) {
		switch(opt) {
			case 'c':
				desired_class = strtol(optarg, NULL, 0);
				break;
			case 'm':
				desired_classmask = strtol(optarg, NULL, 0);
				break;
			case 'h':
				printf ("Usage: pcimodules [--help]\n"
					"  Lists kernel modules corresponding to PCI devices currently plugged"
					"  into the computer.\n");
		}
	}

	read_pcimap();
	match_pci_modules();
	return 0;
}
