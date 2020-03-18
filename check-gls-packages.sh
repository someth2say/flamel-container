#!/bin/sh

echo
echo "This script checks that your container is updated accoding to the latest releases of the packages in the curriculum Yum repository."


function error {
    echo -en "\e[1m\e[31m" 1>&2
    echo -n "$*" 1>&2
    echo -en "\e[0m" 1>&2
    echo 1>&2
}


function ok {
    echo -en "\e[1m\e[32m"
    echo -n "$*"
    echo -en "\e[0m"
    echo
}


function remove_distros {
    sed -e 's/.noarch//' | sed -e 's/.el7//' | sed -e 's/.fc30//'
}


repourl='http://wiki.gls.redhat.com/curriculum-repos/fedora/30/x86_64'

check=true
status=$(curl --connect-timeout 6 -so /dev/null -w '%{http_code}' "${repourl}/")
if [ "${status}" != '200' ]
then
    error
    error "Cannot talk to the old GLS wiki, that also hosts the GLS yum repositories."
    error "Are you sure you are connected to the corporate VPN?"
    check=false
fi

count=0
echo
for package in flamel redhat-training-xsl publican-gls-redhat-new reveal-js-slide-generator
do
    echo -n " · Checking the '${package}' package: "
    if ! rpm -q "${package}" &>/dev/null
    then
        error 'MISSING'
        error "   Your container does not have a package named '${package}'"
        let count=count+1
    else
        local=$(rpm -q --qf "%{VERSION}-%{RELEASE}" "${package}" | remove_distros)
        echo -n "${local} "
        if "${check}"
        then
            #XXX very ugly pipeline, I hope someone review this and comes with a simpler and more reliable alternative
            remote=$(curl -s "${repourl}/" | sed -e 's/<[^>]*>//g' | grep '.rpm' | awk -F.rpm '{print $1}' | grep "${package}" | sed 's/^\(.*\)-\([^-]\{1,\}\)-\([^-]\{1,\}\)$/\2-\3/' | remove_distros | sort | tail -n1)
            if [ "${local}" = "${remote}" ]
            then
                ok 'OK'
            else
                error 'OUTDATED'
                error "   Container package is at version '${local}'."
                error "   Repository package is at version '${remote}'."
                let count=count+1
            fi
        else
            echo "[not checked]"
        fi
    fi
done

echo
if "${check}" 
then
    if [ "${count}" = "0" ]
    then
        ok 'Your container is Ok to build GLS books and slides.'
    else
        error 'Your container is NOT Ok to build GLS books and slides.'
        error 'You are adivised to update your container and/or your wrapper script.'
    fi
fi
