# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7} )

inherit linux-info python-any-r1

DESCRIPTION="interactive process viewer"
HOMEPAGE="https://hisham.hm/htop/"
SRC_URI="https://hisham.hm/htop/releases/${PV}/${P}.tar.gz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ia64 ~mips ppc ppc64 ~riscv sparc x86 ~amd64-linux ~x86-linux ~x64-macos"
IUSE="kernel_FreeBSD kernel_linux openvz unicode vserver"

RDEPEND="sys-libs/ncurses:0=[unicode?]"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${P}-gcc-10.patch )
DOCS=( ChangeLog README )

CONFIG_CHECK="~TASKSTATS ~TASK_XACCT ~TASK_IO_ACCOUNTING ~CGROUPS"

pkg_setup() {
	if ! has_version sys-process/lsof; then
		ewarn "To use lsof features in htop(what processes are accessing"
		ewarn "what files), you must have sys-process/lsof installed."
	fi

	python-any-r1_pkg_setup
	linux-info_pkg_setup
}

src_prepare() {
	rm missing || die

	default

	python_fix_shebang scripts/MakeHeader.py
}

src_configure() {
	[[ $CBUILD != $CHOST ]] && export ac_cv_file__proc_{meminfo,stat}=yes #328971

	local myeconfargs=(
		# fails to build against recent hwloc versions
		--disable-hwloc
		--enable-taskstats
		$(use_enable kernel_linux cgroup)
		$(use_enable kernel_linux linux-affinity)
		$(use_enable openvz)
		$(use_enable unicode)
		$(use_enable vserver)
	)
	econf ${myeconfargs[@]}
}
