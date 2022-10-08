include $(TOPDIR)/rules.mk

PKG_FIXUP:=autoreconf

PKG_NAME:=e2guardian
PKG_VERSION:=5.5.0r-pre0
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=libtool
PKG_INSTALL:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/e2guardian/e2guardian.git
PKG_SOURCE_VERSION:=289335e189b7e5c77e3f2a0371490b5ddd6c8e6e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/e2guardian
	SECTION:=examples
	CATEGORY:=Examples
	TITLE:=e2guardian
	DEPENDS:=+zlib +libpcre +libstdcpp +libc +libopenssl 
endef

define Package/e2guardian/description
	E2guardian is a fork of Dansguardian Project with many improvements and bug fixes and an active development community.
	Features: Built-in content scanner plugin system which includes AV scanning, can be configured to have multiple filter configurations to provide varying degrees of web filtering to different groups of users, SSL Inspection (Version 3.1 Needed), NTLM and persistent connection support, digest authentication support, basic authentication support, IP authentication support, DNS authentication support, header analysis and manipulation - you can also manipulate cookies, large file (2GB+) download & scanning support, whitelist domains and urls, blacklist domains and urls, greylist domains and urls, deny regular Expressions on urls, body content, and headers (also in greylist mode), URL regular expression replacement so you can for example force safe search in search engines, deep URL scanning to spot URLs in URLs to for example block images in Google images, advanced advert blocking, blanket SSL blocking so you can block SSL anonymous proxies (without using SSL Bump), referer exceptions based on URL, time based Blocking
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/.
	(cd $(PKG_BUILD_DIR); tar -xvzf $(PKG_SOURCE))
	mv $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/* $(PKG_BUILD_DIR)/.
	sed -i 's/nobody/root/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-clamd@<:@=no@:>@/--enable-clamd@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-icap@<:@=no@:>@/--enable-icap@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-commandline@<:@=no@:>@/--enable-commandline@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-email@<:@=no@:>@/--enable-email@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-ntlm@<:@=no@:>@/--enable-ntlm@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-pcre@<:@=no@:>@/--enable-pcre@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	sed -i 's/--enable-sslmitm@<:@=no@:>@/--enable-sslmitm@<:@=yes@:>@/' $(PKG_BUILD_DIR)/configure.ac
	(cd $(PKG_BUILD_DIR); ./autogen.sh)
	$(Build/Patch)
endef

CONFIGURE_ARGS += \
	--enable-clamd=yes \
	--with-proxyuser=root \
	--with-proxygroup=root \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-icap=yes \
	--enable-commandline=yes \
	--enable-email=yes \
	--enable-ntlm=yes \
	--enable-pcre=yes \
	--enable-sslmitm=yes

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		TARGET_LDFLAGS="-lzlib -llibpcre -llibstdcpp" \
		LIBTOOL:="$(STAGING_DIR)/host/libltdl/bin/libtool" 
endef

define Package/e2guardian/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/e2guardian $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/e2guardian
	$(INSTALL_DIR) $(1)/usr/share/e2guardian
	PKG_INSTALL_DIR="$(PKG_BUILD_DIR)"/install
	$(CP) -r $(PKG_INSTALL_DIR)/etc/e2guardian/* $(1)/etc/e2guardian/
	$(CP) -r $(PKG_INSTALL_DIR)/usr/share/e2guardian/* $(1)/usr/share/e2guardian/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/e2guardian.init $(1)/etc/init.d/e2guardian	
endef


define Package/e2guardian/postinst
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		if [ -n /var/log/e2guardian ]; then
			mkdir /var/log/e2guardian
		fi
		touch /var/log/e2guardian/access.log
	fi
	exit 0
endef
	
$(eval $(call BuildPackage,e2guardian))
