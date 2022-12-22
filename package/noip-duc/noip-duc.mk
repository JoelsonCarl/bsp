################################################################################
#
# noip-duc
#
################################################################################

NOIP_DUC_VERSION = 2.1.9-1
NOIP_DUC_SOURCE = noip-duc-linux.tar.gz
NOIP_DUC_SITE = http://www.noip.com/client/linux
NOIP_DUC_LICENSE = GPL-2.0-or-later
NOIP_DUC_LICENSE_FILES = COPYING

define NOIP_DUC_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

# The install target in the Makefile from No-IP tries to run the binary, but we are cross-compiled,
# so we'll manually install the binary.
define NOIP_DUC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -d -m 755 $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 700 $(@D)/noip2 $(TARGET_DIR)/usr/bin
endef

define NOIP_DUC_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D $(NOIP_DUC_PKGDIR)/SXXnoip_duc \
		$(TARGET_DIR)/etc/init.d/S$(BR2_PACKAGE_NOIP_DUC_INIT_NUM)noip_duc
endef

$(eval $(generic-package))
