# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs flag-o-matic secureboot

DESCRIPTION="SYSLINUX, PXELINUX, ISOLINUX, EXTLINUX and MEMDISK bootloaders"
HOMEPAGE="https://www.syslinux.org/"
MY_P=${P/_/-}
SRC_URI="https://git.zytor.com/syslinux/syslinux.git/snapshot/${MY_P}.tar.gz"

S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="-* ~amd64 ~x86"
IUSE="abi_x86_32 abi_x86_64 +bios +uefi"
REQUIRED_USE="|| ( bios uefi )
	uefi? ( || ( abi_x86_32 abi_x86_64 ) )"

RESTRICT="test"

BDEPEND="
	dev-lang/perl
	bios? ( dev-lang/nasm )
	sys-devel/gcc:*
"
RDEPEND="
	sys-apps/util-linux
	sys-fs/mtools
	dev-perl/Crypt-PasswdMD5
	dev-perl/Digest-SHA1
"
DEPEND="${RDEPEND}
	uefi? ( sys-boot/gnu-efi[abi_x86_32(-)?,abi_x86_64(-)?] )
	virtual/os-headers
"

QA_EXECSTACK="usr/share/syslinux/*"
QA_WX_LOAD="usr/share/syslinux/*"
QA_PRESTRIPPED="usr/share/syslinux/.*"
QA_FLAGS_IGNORED=".*"

pkg_setup() {
	use uefi && secureboot_pkg_setup
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}/6.04_pre1"
		"${FILESDIR}/6.04_pre3"
	)
	default

	# Force gcc because build failed with clang, #729426
	if ! tc-is-gcc ; then
		ewarn "syslinux can be built with gcc only."
		ewarn "Ignoring CC=$(tc-getCC) and forcing ${CHOST}-gcc"
		export CC=${CHOST}-gcc
		export CXX=${CHOST}-g++
		tc-is-gcc || die "tc-is-gcc failed in spite of CC=${CC}"
	fi
}

efimake() {
	local ABI="${1}"
	local libdir="$(get_libdir)"
	shift
	local args=(
		EFIINC="${ESYSROOT}/usr/include/efi"
		LIBDIR="${ESYSROOT}/usr/${libdir}"
		LIBEFI="${ESYSROOT}/usr/${libdir}/libefi.a"
		"${@}"
	)
	emake "${args[@]}"
}

src_compile() {
	filter-lto #863722

	local DATE=$(date -u -r NEWS +%Y%m%d)
	local HEXDATE=$(printf '0x%08x' "${DATE}")

	tc-export AR CC LD OBJCOPY RANLIB
	unset CFLAGS LDFLAGS

	if use bios; then
		emake bios DATE="${DATE}" HEXDATE="${HEXDATE}" UPX=false
	fi
	if use uefi; then
		if use abi_x86_32; then
			efimake x86 efi32 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
		if use abi_x86_64; then
			efimake amd64 efi64 DATE="${DATE}" HEXDATE="${HEXDATE}"
		fi
	fi
}

src_install() {
	local firmware=( $(usev bios) )
	if use uefi; then
		use abi_x86_32 && firmware+=( efi32 )
		use abi_x86_64 && firmware+=( efi64 )
	fi
	local args=(
		INSTALLROOT="${ED}"
		MANDIR='$(DATADIR)/man'
		"${firmware[@]}"
		install
	)
	emake -j1 "${args[@]}"
	if use bios; then
		mv "${ED}"/usr/bin/keytab-{lilo,syslinux} || die
	fi
	einstalldocs
	dostrip -x /usr/share/syslinux

	use uefi && secureboot_auto_sign --in-place
}
