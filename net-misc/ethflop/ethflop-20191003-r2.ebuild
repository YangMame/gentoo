# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd toolchain-funcs

DESCRIPTION="A network-backed floppy emulator for DOS"
HOMEPAGE="http://ethflop.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.zip"
S="${WORKDIR}"

LICENSE="ISC"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="tsr"

BDEPEND="
	app-arch/unzip
	tsr? ( dev-lang/nasm )
"

PATCHES=( "${FILESDIR}/${P}-makefile.patch" )

src_compile() {
	tc-export CC
	default

	use tsr && emake tsr
}

src_install() {
	dobin ethflopd

	if use tsr; then
		insinto /usr/share/ethflop
		doins ethflop.com
	fi

	newinitd "${FILESDIR}"/ethflopd.initd ethflopd
	newconfd "${FILESDIR}"/ethflopd.confd ethflopd
	systemd_newunit "${FILESDIR}"/ethflopd.service-r1 ethflopd.service

	dodoc ethflop.txt
}
