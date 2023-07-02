#!/bin/sh

pkg_dir_arch=$1
pkg_dir_name=$(echo "${pkg_dir_arch}" | cut -d'@' -f 1)
pkg_arch=$(echo "${pkg_dir_arch}" | cut -d'@' -f 2)
maintainer=$2
gpg_usrKey=$3
gpg_usr=$(echo "${gpg_usrKey}" | cut -d'@' -f 1)
gpg_key=$(echo "${gpg_usrKey}" | cut -d'@' -f 2)

# example : create_signed_debian_pkg.sh sddm@amd64 "Arijit Bhowmick" sys41x4@212D2254446D6161AA880823141531775A06F762


do_hash() {
    HASH_NAME=$1
    HASH_CMD=$2
    echo "${HASH_NAME}:" >> ../CHECKSUM
    for f in $(find -type f); do
        f=$(echo $f | cut -c3-) # remove ./ prefix
        if [ "$f" = "Release" ]; then
            continue
        fi
        echo " $(${HASH_CMD} ${f}  | cut -d" " -f1) $(wc -c $f)" >> ../CHECKSUM
    done
}


echo "BUILD_${pkg_dir_name} | ${gpg_usr}@${gpg_key}"
# exit # for testing variables uncomment this line

sudo rm -r "BUILD_${pkg_dir_name}"

mkdir -p "BUILD_${pkg_dir_name}/source" && \
mkdir -p "BUILD_${pkg_dir_name}/BUILD" && \
mv "${pkg_dir_name}" "BUILD_${pkg_dir_name}/BUILD/${pkg_dir_name}" && \
cd "BUILD_${pkg_dir_name}/BUILD/${pkg_dir_name}" && \
tar -czvf "../${pkg_dir_name}.orig.tar.gz" ./ && \
sudo -u "${gpg_usr}" /bin/sh -c " \
export DEB_BUILD_ARCH=${pkg_arch} && \
dpkg-buildpackage --pre-clean -us -uc "-k${gpg_key}" \
" && cd ../ && pwd && \
#exit
release_name=$(echo ./*.changes | cut -d'_' -f 2) && \
mv "./${pkg_dir_name}.orig.tar.gz" \
"./${pkg_dir_name}_${release_name}.orig.tar.gz" && \
mv "${pkg_dir_name}" "../../" && \
## Generage checksums of the packages
do_hash "MD5Sum" "md5sum" && \
do_hash "SHA1" "sha1sum" && \
do_hash "SHA256" "sha256sum" && \
mv ../CHECKSUM "${pkg_dir_name}_${release_name}.CHECKSUM" && \
mv ./*.orig.tar.gz "../source/" && \
cd ../../

echo " Unsigned BUILDS are available at BUILD_${pkg_dir_name}"

exit
