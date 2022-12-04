#!/bin/bash
set -o pipefail

bsp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
print_help=0
output_dir=""

print_usage() {
	cat << EOF
$0 [options] boardname

Builds a specified BSP.

WARNING: If [output-dir]/[boardname] already exists, it will be erased and a clean build will be
performed.

Args:
	boardname: a BSP config in the configs/ folder, excluding the "_defconfig" suffix.

Options:
	-h,--help: Print this help and exit
	-o,--output-dir: The directory in which to build bsps; defaults to "builds/" within this
	                 directory
EOF
}

# Note that we use "$@" to let each command-line parameter expand to a
# separate word. The quotes around "$@" are essential!
# We need TEMP as the 'eval set --' would nuke the return value of getopt.
TEMP=$(getopt -o 'ho:' --long 'help,output-dir:' -n 'build.sh' -- "$@")

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
	case "$1" in
	'-h'|'--help')
		print_help=1
		shift
		continue
	;;
	'-o'|'--output-dir')
		output_dir="$2"
		shift 2
		continue
	;;
	'--')
		shift
		break
	;;
	*)
		echo 'Internal error!' >&2
		exit 1
	;;
	esac
done

# If help is specified, print and exit
if [ ${print_help} -eq 1 ]; then
	print_usage
	exit 1
fi

# Expect one remaining argument, the boardname; verify it exists
if [ $# -ne 1 ]; then
	echo "No boardname given, or too many arguments!"
	print_usage
	exit 1
fi
boardname=$1
if ! [ -e "${bsp_dir}/configs/${boardname}_defconfig" ]; then
	echo "No '${boardname}_defconfig' file found!"
	print_usage
	exit 1
fi

# Set output directory variable
if [ -z "${output_dir}" ]; then
	output_dir="${bsp_dir}/builds"
fi
mkdir -p "${output_dir}"

# Delete any existing output directory
if [ -d "${output_dir}/${boardname}" ]; then
	echo "ERASING EXISTING ${output_dir}/${boardname} DIRECTORY!"
	rm -rf "${output_dir:?}/${boardname:?}"
fi

mkdir -p "${output_dir}/${boardname}"

# Go into buildroot and initialize build
pushd "${bsp_dir}/externals/buildroot" || exit 1
if ! make BR2_EXTERNAL="${bsp_dir}" O="${output_dir}/${boardname}" "${boardname}_defconfig"; then
	echo "Failure setting up build directory"
	popd || exit 1
	exit 1
fi
popd || exit 1

# Go into build directory, get sources, and build
pushd "${output_dir}/${boardname}" || exit 1
if ! make source | tee "${output_dir}/${boardname}/logbuild.log"; then
	echo "Failure downloading sources; check logbuild.log"
	popd || exit 1
	exit 1
fi
if ! make all | tee -a "${output_dir}/${boardname}/logbuild.log"; then
	echo "Failure during build; check logbuild.log"
	popd || exit 1
	exit 1
fi
popd || exit 1

echo "Build '${boardname}': SUCCESS" | tee -a "${output_dir}/${boardname}/logbuild.log"
