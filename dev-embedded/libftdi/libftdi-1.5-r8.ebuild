# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_P="${PN}1-${PV}"
PYTHON_COMPAT=( python3_{11..13} )
inherit cmake python-single-r1

if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="git://developer.intra2net.com/${PN}"
else
	SRC_URI="https://www.intra2net.com/en/developer/${PN}/download/${MY_P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"
	KEYWORDS="amd64 arm arm64 ~loong ~mips ppc ppc64 ~riscv sparc x86"
fi

DESCRIPTION="Userspace access to FTDI USB interface chips"
HOMEPAGE="https://www.intra2net.com/en/developer/libftdi/"

LICENSE="LGPL-2"
SLOT="1"
IUSE="cxx doc examples python test tools"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

RDEPEND="
	virtual/libusb:1
	cxx? ( dev-libs/boost )
	doc? ( !dev-embedded/libftdi:0[doc] )
	python? ( ${PYTHON_DEPS} )
	tools? ( dev-libs/confuse:= )
"
DEPEND="${RDEPEND}
	test? ( dev-libs/boost )
"
BDEPEND="
	doc? ( app-text/doxygen )
	python? ( >=dev-lang/swig-4.2.0 )
"

PATCHES=(
	"${FILESDIR}"/${P}-tests-no-cxx.patch
	"${FILESDIR}"/${P}-cmake-cxx.patch
	"${FILESDIR}"/${P}-py312.patch
	"${FILESDIR}"/${P}-cmake4.patch
	"${FILESDIR}"/${P}-swig-4.3.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DFTDIPP=$(usex cxx)
		-DDOCUMENTATION=$(usex doc)
		-DEXAMPLES=$(usex examples)
		-DPYTHON_BINDINGS=$(usex python)
		-DBUILD_TESTS=$(usex test)
		-DFTDI_EEPROM=$(usex tools)
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DSTATICLIBS=OFF
	)
	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}/test" || die
	LD_LIBRARY_PATH="${BUILD_DIR}/src" ./test_libftdi1 -l all || die
}

src_install() {
	cmake_src_install

	use python && python_optimize
	dodoc AUTHORS ChangeLog README TODO

	if use doc ; then
		# Clean up man pages with too generic names. #356369
		rm -vf "${BUILD_DIR}"/doc/man/man3/_* || die

		doman "${BUILD_DIR}"/doc/man/man3/*
		dodoc -r "${BUILD_DIR}"/doc/html
	fi

	if use examples ; then
		docinto examples
		dodoc examples/*.c
	fi
}
