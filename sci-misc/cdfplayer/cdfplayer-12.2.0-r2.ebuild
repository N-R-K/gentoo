# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="Wolfram Player for the interactive Computable Document Format (CDF)"
HOMEPAGE="http://www.wolfram.com/cdf-player/"
SRC_URI="WolframPlayer_${PV}_LINUX.sh"
S="${WORKDIR}"

LICENSE="WolframCDFPlayer"
KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
RESTRICT="strip mirror bindist fetch"

# this list comes from lsof output
# probably there are still some libraries missing
RDEPEND="
	dev-libs/expat
	dev-libs/icu
	dev-libs/libxml2:=
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	sys-libs/ncurses-compat:5
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXt
"

# we need this a few times
MPN="WolframPlayer"
MPV=$(ver_cut 1-2)

# we might as well list all files in all QA variables...
QA_PREBUILT="opt/*"

pkg_nofetch() {
	einfo "Sadly Wolfram provides no permanent link to the player files."
	einfo "Please download the Wolfram CFD Player installation file ${SRC_URI} from"
	einfo "${HOMEPAGE} and place it into your DISTDIR directory."
}

src_unpack() {
	${CONFIG_SHELL:-${BASH}} "${DISTDIR}/${A}" --nox11 --confirm --keep -- -auto "-targetdir=${S}/opt/Wolfram/${MPN}/${MPV}" "-execdir=${S}/opt/bin"
}

src_install() {
	local ARCH=$(usev amd64 '-x86-64')

	# move all over
	(
		insinto /
		doins -r opt
	)

	# the autogenerated symlinks point into sandbox, redo
	rm "${ED}"/opt/bin/* || die
	dosym ../Wolfram/${MPN}/${MPV}/Executables/wolframplayer opt/bin/wolframplayer
	dosym ../Wolfram/${MPN}/${MPV}/Executables/WolframPlayer opt/bin/WolframPlayer

	# fix some embedded paths and install desktop files
	local filename
	while IFS="" read -d $'\0' -r filename ; do
		einfo "Fixing ${filename}"
		sed -e "s:${S}::g" -e 's:^\t\t::g' -i "${filename}" || die
		echo "Categories=Physics;Science;Engineering;2DGraphics;Graphics;" >> "${filename}" || die
		domenu "${filename}"
	done < <(find "${ED}" -type f -name "wolfram-cdf12.desktop" -print0)

	# install a wrapper
	newbin - ${PN} <<- _EOF_
		#!/usr/bin/env sh
		LD_PRELOAD=${EPREFIX}/usr/$(get_libdir)/libfreetype.so.6:${EPREFIX}/lib/libz.so.1 ${EPREFIX}/opt/Wolfram/${MPN}/${MPV}/Executables/wolframplayer \$*
	_EOF_
}
