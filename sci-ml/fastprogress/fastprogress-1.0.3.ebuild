# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Simple and flexible progress bar for Jupyter Notebook and console"
HOMEPAGE="https://fastprogress.fast.ai/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
