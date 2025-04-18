# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby31 ruby32 ruby33 ruby34"

RUBY_FAKEGEM_EXTRAINSTALL="VERSION"
RUBY_FAKEGEM_GEMSPEC="jmespath.gemspec"
RUBY_FAKEGEM_RECIPE_TEST="rspec3"

inherit ruby-fakegem

DESCRIPTION="Implements JMESPath for Ruby"
HOMEPAGE="https://github.com/jmespath/jmespath.rb"
SRC_URI="https://github.com/jmespath/jmespath.rb/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RUBY_S="${PN}.rb-${PV}"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~arm64"

all_ruby_prepare() {
	sed -i -e '/simplecov/I s:^:#:' \
		spec/{compliance_spec,compliance_without_errors_spec,spec_helper}.rb || die
	sed -i -e '/bundler/I s:^:#:' spec/spec_helper.rb || die
}
