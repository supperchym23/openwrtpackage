include $(TOPDIR)/rules.mk

PKG_NAME:=ufdbGuard
PKG_VERSION:=1.35.3
PKG_RELEASE:=1

PKG_LICENSE:=GPL
PKG_MAINTAINER:=Andy Savage <andy@savage.hk>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.urlfilterdb.com/files/downloads/                        
#PKG_MD5SUM:=92632ea336f07b4480f3ff103be47585

include $(INCLUDE_DIR)/package.mk

define Package/ufdbGuard
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=ufdbGuard
  URL:=http://www.urlfilterdb.com/
endef

define Package/ufdbGuard/description
 Description goes here.
endef

define Build/Configure
  $(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

define Package/bridge/install
        $(INSTALL_DIR) $(1)/usr/sbin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
