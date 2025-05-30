# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Recursive descent parsing library based on functional combinators"
HOMEPAGE="
	https://github.com/vlasovskikh/funcparserlib/
	https://pypi.org/project/funcparserlib/
"
SRC_URI="
	https://github.com/vlasovskikh/funcparserlib/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	test? (
		dev-python/six[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests unittest
