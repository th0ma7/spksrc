service_postinst ()
{
    # Make sure local/bin path exists
    mkdir -p /usr/local/bin

    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/corelist /usr/local/bin/corelist
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/cpan /usr/local/bin/cpan
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/enc2xs /usr/local/bin/enc2xs
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/encguess /usr/local/bin/encguess
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/h2ph /usr/local/bin/h2ph
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/h2xs /usr/local/bin/h2xs
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/instmodsh /usr/local/bin/instmodsh
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/json_pp /usr/local/bin/json_pp
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/libnetcfg /usr/local/bin/libnetcfg
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/perl /usr/local/bin/perl
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/perlbug /usr/local/bin/perlbug
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/perldoc /usr/local/bin/perldoc
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/perlivp /usr/local/bin/perlivp
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/perlthanks /usr/local/bin/perlthanks
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/piconv /usr/local/bin/piconv
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/pl2pm /usr/local/bin/pl2pm
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/pod2html /usr/local/bin/pod2html
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/pod2man /usr/local/bin/pod2man
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/pod2text /usr/local/bin/pod2text
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/pod2usage /usr/local/bin/pod2usage
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/podchecker /usr/local/bin/podchecker
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/podselect /usr/local/bin/podselect
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/prove /usr/local/bin/prove
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/ptar /usr/local/bin/ptar
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/ptardiff /usr/local/bin/ptardiff
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/ptargrep /usr/local/bin/ptargrep
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/shasum /usr/local/bin/shasum
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/splain /usr/local/bin/splain
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/xsubpp /usr/local/bin/xsubpp
    ln -s /var/packages/${SYNOPKG_PKGNAME}/target/bin/zipdetails /usr/local/bin/zipdetails
}

service_postuninst ()
{
    # Remove perl and tools links from the PATH
    rm -f /usr/local/bin/corelist
    rm -f /usr/local/bin/cpan
    rm -f /usr/local/bin/enc2xs
    rm -f /usr/local/bin/encguess
    rm -f /usr/local/bin/h2ph
    rm -f /usr/local/bin/h2xs
    rm -f /usr/local/bin/instmodsh
    rm -f /usr/local/bin/json_pp
    rm -f /usr/local/bin/libnetcfg
    rm -f /usr/local/bin/perl
    rm -f /usr/local/bin/perlbug
    rm -f /usr/local/bin/perldoc
    rm -f /usr/local/bin/perlivp
    rm -f /usr/local/bin/perlthanks
    rm -f /usr/local/bin/piconv
    rm -f /usr/local/bin/pl2pm
    rm -f /usr/local/bin/pod2html
    rm -f /usr/local/bin/pod2man
    rm -f /usr/local/bin/pod2text
    rm -f /usr/local/bin/pod2usage
    rm -f /usr/local/bin/podchecker
    rm -f /usr/local/bin/podselect
    rm -f /usr/local/bin/prove
    rm -f /usr/local/bin/ptar
    rm -f /usr/local/bin/ptardiff
    rm -f /usr/local/bin/ptargrep
    rm -f /usr/local/bin/shasum
    rm -f /usr/local/bin/splain
    rm -f /usr/local/bin/xsubpp
    rm -f /usr/local/bin/zipdetails
}
