#!/bin/bash
#
# Do post-build work before we generate the rootfs image.

bsp_dir="${BR2_EXTERNAL_JOELSONCARL_PATH}"
board_dir="${bsp_dir}/board/rpi4_64_router"

# Run private configuration script if it exists
if [ -f "${board_dir}/private_config.sh" ]; then
	# shellcheck disable=SC1090
	source "${board_dir}/private_config.sh"
fi
