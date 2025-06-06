PATH="${SYNOPKG_PKGDEST}/bin:$PATH"

service_postinst ()
{
    echo "Install pip"
    # use --default-pip to install 'pip' too (not only pip3 and pip 3.12)
    # required for packages published with former version of 'install_python_wheels'
    # that still call pip and not pip3
    ${SYNOPKG_PKGDEST}/bin/python3 -m ensurepip --default-pip
    
    # Install the wheels
    install_python_wheels

    # Log installation informations
    echo "Installed version: $( ${SYNOPKG_PKGDEST}/bin/python3 --version 2>&1 )"

    # Byte-compile in background
    PYTHON_SHORT_VER=$(${SYNOPKG_PKGDEST}/bin/python3 -c 'import sys; print("{0}.{1}".format(*sys.version_info[:2]))')
    ${SYNOPKG_PKGDEST}/bin/python3 -m compileall -q -f ${SYNOPKG_PKGDEST}/lib/python${PYTHON_SHORT_VER} </dev/null &>/dev/null &
    ${SYNOPKG_PKGDEST}/bin/python3 -OO -m compileall -q -f ${SYNOPKG_PKGDEST}/lib/python${PYTHON_SHORT_VER} </dev/null &>/dev/null &
}

