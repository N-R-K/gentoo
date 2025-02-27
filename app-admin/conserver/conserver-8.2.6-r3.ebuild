# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools pam ssl-cert

DESCRIPTION="Serial Console Manager"
HOMEPAGE="https://www.conserver.com"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="BSD BSD-with-attribution"
SLOT="0"
KEYWORDS="~alpha amd64 ppc ppc64 ~sparc x86"
IUSE="ipv6 freeipmi kerberos pam ssl test tcpd"
RESTRICT="!test? ( test )"

DEPEND="net-libs/libnsl:=
	virtual/libcrypt:=
	freeipmi? ( sys-libs/freeipmi:= )
	kerberos? (
		virtual/krb5
		net-libs/libgssglue
	)
	ssl? ( dev-libs/openssl:0= )
	pam? ( sys-libs/pam )
	tcpd? ( sys-apps/tcp-wrappers )
"
RDEPEND="${DEPEND}
	pam? ( sys-auth/pambase )"

DOCS=( CHANGES FAQ PROTOCOL README.md conserver/Sun-serial contrib/maketestcerts)

PATCHES=(
	"${FILESDIR}/${PN}-8.2.6-autoconf-2.70.patch" #750230
)

src_prepare() {
	default
	sed -e '/^INSTALL_PROGRAM/s:-s::' \
		-i {console,conserver,autologin,contrib/chat}/Makefile.in || die
	eautoreconf
}

src_configure() {
	local myconf=(
		$(use_with ipv6)
		$(use_with freeipmi)
		$(use_with kerberos gssapi)
		$(use_with ssl openssl)
		$(use_with pam)
		$(use_with tcpd libwrap)
		--without-dmalloc
		--with-cffile=conserver/conserver.cf
		--with-logfile=/var/log/conserver.log
		--with-master=localhost
		--with-pidfile=/run/conserver.pid
		--with-port=7782
		--with-pwdfile=conserver/conserver.passwd
	)
	econf "${myconf[@]}"
}

src_install() {
	emake DESTDIR="${D}" exampledir="/usr/share/doc/${PF}/examples" install

	keepdir /var/consoles
	fowners daemon:daemon /var/consoles
	fperms 700 /var/consoles

	newinitd "${FILESDIR}"/conserver.initd-r1 conserver
	newconfd "${FILESDIR}"/conserver.confd-r1 conserver

	dodir /etc/conserver
	fperms 700 /etc/conserver
	insinto /etc/conserver
	newins "${S}"/conserver.cf/conserver.cf conserver.cf.sample
	newins "${S}"/conserver.cf/conserver.passwd conserver.passwd.sample

	einstalldocs
	docinto examples
	dodoc -r conserver.cf/samples/.

	if use pam; then
		newpamd "${FILESDIR}"/conserver.pam-pambase conserver
	fi
}

src_test() {
	# hangs without -j1
	emake -j1 test
}

pkg_postinst() {
	if use ssl; then
		if [[ ! -f "${EROOT}"/etc/ssl/conserver/conserver.key ]]; then
			install_cert /etc/ssl/conserver/conserver
		fi
	fi
}
