################################################################################
#
# dnsmasq-blocklists
#
################################################################################

DNSMASQ_BLOCKLISTS_VERSION = 1.0
DNSMASQ_BLOCKLISTS_SITE = $(BR2_EXTERNAL_JOELSONCARL_PATH)/package/dnsmasq-blocklists/scripts
DNSMASQ_BLOCKLISTS_SITE_METHOD = local
DNSMASQ_BLOCKLISTS_DEPENDENCIES = dnsmasq

# Create blocklist install directory
define DNSMASQ_BLOCKLISTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -d -m 755 $(TARGET_DIR)/$(BR2_PACKAGE_DNSMASQ_BLOCKLISTS_INSTALL_DIR)
endef

# Install script for github StevenBlack/hosts dynamic-retrieval script
ifeq ($(BR2_PACKAGE_DNSMASQ_BLOCKLISTS_STEVEN_BLACK_HOSTS_DYNAMIC),y)
define DNSMASQ_BLOCKLISTS_INSTALL_INIT_STEVEN_BLACK_HOSTS_DYNAMIC
	$(INSTALL) -m 755 -D $(@D)/S79dnsmasq_sb_block \
		$(TARGET_DIR)/etc/init.d/S$(BR2_PACKAGE_DNSMASQ_BLOCKLISTS_STEVEN_BLACK_HOSTS_DYNAMIC_INIT_NUM)dnsmasq_sb_block
endef
endif

define DNSMASQ_BLOCKLISTS_INSTALL_INIT_SYSV
	$(DNSMASQ_BLOCKLISTS_INSTALL_INIT_STEVEN_BLACK_HOSTS_DYNAMIC)
endef

$(eval $(generic-package))
