# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs

DESCRIPTION="a weather application, it shows the weather in a graphical way"
HOMEPAGE="http://wiki.colar.net/wmfrog_dockapp"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~sparc x86"

RDEPEND="x11-libs/libXext
	x11-libs/libXpm
	x11-libs/libX11"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

S="${WORKDIR}/Src"

PATCHES=( "${FILESDIR}"/${P}-gcc-10.patch )
DOCS=( ../{CHANGES,HINTS} )

src_prepare() {
	default
	emake clean
}

src_compile() {
	# bug #944305
	append-cflags -std=gnu17

	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" INCDIR="" \
		LIBDIR="" SYSTEM="${LDFLAGS}"
}
