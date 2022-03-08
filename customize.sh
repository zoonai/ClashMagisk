SKIPUNZIP=1
ASH_STANDALONE=1

status=""
architecture=""
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/adb/clash"
modules_dir="/data/adb/modules"
bin_path="/system/bin/"
dns_path="/system/etc"
clash_adb_dir="/data/adb"
clash_service_dir="/data/adb/service.d"
sdcard_dir="/sdcard/Download"
busybox_data_dir="/data/adb/magisk/busybox"
ca_path="${dns_path}/security/cacerts"
clash_data_dir_core="${clash_data_dir}/core"
CPFM_mode_dir="${modules_dir}/clash_premium"
clash_data_sc="${clash_data_dir}/scripts"
clash_data_acc="${clash_data_dir}/accounts"
clash_data_rule="${clash_data_dir}/rules"
mod_config="${clash_data_sc}/clash.config"
geoip_file_path="${clash_data_dir}/Country.mmdb"
yacd_dir="${clash_data_dir}/yacd-gh-pages"

if [ $BOOTMODE ! = true ] ; then
  abort "ERROR = Silahkan install di Magisk Manager."
fi

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d ${MODPATH} >&2

ui_print "- Persiapan Clash execute environment."
ui_print "- Membuat folder Clash."
mkdir -p ${clash_data_dir}
mkdir -p ${clash_data_dir_core}
mkdir -p ${MODPATH}${ca_path}
mkdir -p ${clash_data_dir}/yacd-gh-pages
mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}/run
mkdir -p ${clash_data_dir}/scripts
mkdir -p ${clash_data_dir}/accounts
mkdir -p ${clash_data_dir}/rules

download_clash_zip="${clash_data_dir}/run/clash-core.zip"
download_yacd_zip="${clash_data_dir}/yacd-gh-pages.zip"
download_scripts_zip="${clash_data_dir}/master.zip"
download_cert="${clash_data_dir}/cacert.pem"
download_GeoIP="${clash_data_dir}/GeoIP.dat"
download_GeoSite="${clash_data_dir}/GeoSite.dat"
official_yacd_link="https://github.com/taamarin/yacd/releases/download/v0.3.4/yacd-gh-pages.zip"
official_scripts_link="https://github.com/zoonai/ClashMagisk/archive/refs/heads/master.zip"
official_cert_link="http://curl.haxx.se/ca/cacert.pem"
official_GeoIP_link="https://github.com/v2fly/geoip/releases/latest/download/geoip-only-cn-private.dat"
official_GeoSite_link="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
custom="${sdcard_dir}/clash-core.zip"

if [ -f "${custom}" ]; then
  cp "${custom}" "${download_clash_zip}"
  ui_print "- INFO = Clash-Core khusus ditemukan, memulai penginstalan."
  latest_clash_version=custom
else
  case "${ARCH}" in
    arm)
      version="clash-linux-arm32-v7a.zip"
      ;;
    arm64)
      version="clash-linux-arm64-v8a.zip"
      ;;
    x86)
      version="clash-linux-32.zip"
      ;;
    x64)
      version="clash-linux-64.zip"
      ;;
  esac
  ui_print "- Menggunakan versi: ${version}"
  if [ -f ${sdcard_dir}/"${version}" ]; then
    cp ${sdcard_dir}/"${version}" "${download_clash_zip}"
    ui_print "- INFO = Clash-Core selesai diunduh, memulai penginstalan."
    latest_clash_version=custom
  else
    ui_print "- Download Versi Terbaru Clash Core dari tautan Fork."
    ui_print "- Menghubungkan tautan unduhan Forks-Clash."
    
    forks_clash_link="https://github.com/taamarin/MetaforCfm/releases"

    if [ -x "$(which wget)" ] ; then
      latest_clash_version=`wget -qO- https://api.github.com/repos/taamarin/MetaforCfm/releases | grep -m 1 "tag_name" | grep -o "v[0-9.]*"`
    elif [ -x "$(which curl)" ]; then
      latest_clash_version=`curl -ks https://api.github.com/repos/taamarin/MetaforCfm/releases | grep -m 1 "tag_name" | grep -o "v[0-9.]*"`
    elif [ -x "/data/adb/magisk/busybox" ] ; then
      latest_clash_version=`${busybox_data_dir} wget -qO- https://api.github.com/repos/taamarin/MetaforCfm/releases | grep -m 1 "tag_name" | grep -o "v[0-9.]*"`
    else
      ui_print "- ERROR = Tidak dapat menemukan curl atau wget, silakan instal."
      abort
    fi

    if [ "${latest_clash_version}" = "" ] ; then
      ui_print "- ERROR = Sambungkan tautan unduhan Clash resmi gagal."
      ui_print "- TIPS = Kamu dapat mengunduh Clash Core secara manual,"
      ui_print "      dan simpan di /sdcard/Download"
      abort
    fi
    ui_print "- Unduh inti clash terbaru ${latest_clash_version}-${ARCH}"

    if [ -x "$(which wget)" ] ; then
      wget "${forks_clash_link}/download/${latest_clash_version}/${version}" -O "${download_clash_zip}" >&2
    elif [ -x "$(which curl)" ]; then
      curl "${forks_clash_link}/download/${latest_clash_version}/${version}" -kLo "${download_clash_zip}" >&2
    elif [ -x "/data/adb/magisk/busybox" ] ; then
      ${busybox_data_dir} wget "${forks_clash_link}/download/${latest_clash_version}/${version}" -O "${download_clash_zip}" >&2
    else
      ui_print "- ERROR = Tidak dapat menemukan curl atau wget, silakan instal."
      abort
    fi

    if [ "$?" != "0" ] ; then
      ui_print "- ERROR = Unduh inti clash gagal."
      ui_print "- TIPS = Kamu dapat mengunduh Clash Core secara manual,"
      ui_print "      dan simpan di /sdcard/Download."
      abort
    fi
  fi
fi

ui_print "- Unduh Yet Another Clash Dashboard."
${busybox_data_dir} wget ${official_yacd_link} -O ${download_yacd_zip}
rm -rf "${clash_data_dir}/yacd-gh-pages/*"
unzip -o "${download_yacd_zip}" -d ${clash_data_dir}/yacd-gh-pages/ >&2

ui_print "- Unduh Scripts Clash."
${busybox_data_dir} wget ${official_scripts_link} -O ${download_scripts_zip}
rm -rf "${clash_data_dir}/scripts/*"
unzip -j -o "${download_scripts_zip}" "ClashforMagisk-master/scripts/*" -d ${clash_data_dir}/scripts/ >&2

ui_print "- Unduh Config Accounts Clash."
${busybox_data_dir} wget ${official_scripts_link} -O ${download_scripts_zip}
rm -rf "${clash_data_dir}/accounts/*"
unzip -j -o "${download_scripts_zip}" "ClashforMagisk-master/accounts/*" -d ${clash_data_dir}/accounts/ >&2

ui_print "- Unduh Config Rules Clash."
${busybox_data_dir} wget ${official_scripts_link} -O ${download_scripts_zip}
rm -rf "${clash_data_dir}/rules/*"
unzip -j -o "${download_scripts_zip}" "ClashforMagisk-master/rules/*" -d ${clash_data_dir}/rules/ >&2

ui_print "- Unduh Cert."
${busybox_data_dir} wget ${official_cert_link} -O ${download_cert}
mv -f ${download_cert} ${MODPATH}${ca_path}

ui_print "- Unduh GeoX."
${busybox_data_dir} wget ${official_GeoIP_link} -O ${download_GeoIP}
${busybox_data_dir} wget ${official_GeoSite_link} -O ${download_GeoSite}

ui_print "- Mengunduh Selesai."
ui_print "- Konfigurasi Clash dan file."
if [ ! -d /data/adb/service.d ] ; then
  mkdir -p /data/adb/service.d
fi

if [ -f "${clash_data_dir_core}/clash" ] ; then
  mv -f ${clash_data_dir_core}/clash ${clash_data_dir_core}/clash.bak
fi

if [ -f "${clash_data_dir}/config.yaml" ] ; then
  mv -f ${clash_data_dir}/config.yaml ${clash_data_dir}/config.yaml.bak
fi

if [ ! -f "${dns_path}/resolv.conf" ] ; then
  touch ${MODPATH}${dns_path}/resolv.conf
  echo nameserver 8.8.8.8 > ${MODPATH}${dns_path}/resolv.conf
  echo nameserver 1.1.1.1 >> ${MODPATH}${dns_path}/resolv.conf
fi

# hapus service lama
rm -rf ${MODPATH}/service.sh
rm -rf ${MODPATH}/uninstall.sh
rm -rf ${clash_service_dir}/cfm_service.sh
mv -f ${clash_data_dir}/scripts/config.yaml ${clash_data_dir}/

ui_print "- Eksekusi ZipFile."
if [ ! -f "${MODPATH}/service.sh" ] ; then
  unzip -j -o "${ZIPFILE}" 'service.sh' -d ${MODPATH} >&2
fi

if [ ! -f "${MODPATH}/uninstall.sh" ] ; then
  unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d ${MODPATH} >&2
fi

if [ ! -f "${clash_service_dir}/cfm_service.sh" ] ; then
  unzip -j -o "${ZIPFILE}" 'cfm_service.sh' -d ${clash_service_dir} >&2
fi

ui_print "- Install Clash Eksekusi files."
ui_print "- Memproses Core $ARCH Eksekusi files."
if [ ! -f "${bin_path}/ss" ] ; then
  unzip -j -o "${download_clash_zip}" "ss" -d ${MODPATH}${bin_path} >&2
fi

unzip -j -o "${download_clash_zip}" "clash" -d ${clash_data_dir_core} >&2
unzip -j -o "${download_clash_zip}" "setcap" -d ${MODPATH}${bin_path} >&2
unzip -j -o "${download_clash_zip}" "getcap" -d ${MODPATH}${bin_path} >&2
unzip -j -o "${download_clash_zip}" "getpcaps" -d ${MODPATH}${bin_path} >&2
MODPATH
rm "${download_clash_zip}"
rm "${download_yacd_zip}"
rm "${download_scripts_zip}"
rm -rf ${MODPATH}/scripts
rm -rf ${MODPATH}/cfm_service.sh
rm -rf ${clash_data_dir}/scripts/config.yaml
sleep 1

# generate module.prop
ui_print "- Membuat module.prop."
rm -rf ${MODPATH}/module.prop
touch ${MODPATH}/module.prop
echo "id=ClashMagisk" > ${MODPATH}/module.prop
echo "name=Clash Magisk" >> ${MODPATH}/module.prop
echo -n "version=Module v1.9.1, Core " >> ${MODPATH}/module.prop
echo ${latest_clash_version} >> ${MODPATH}/module.prop
echo "versionCode=20220308" >> ${MODPATH}/module.prop
echo "author=Zoonai" >> ${MODPATH}/module.prop
echo "description=Clash core with service scripts for Android" >> ${MODPATH}/module.prop

ui_print "- Mengatur Perizinan."
set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm_recursive ${clash_service_dir} 0 0 0755 0755
set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
set_perm_recursive ${clash_data_dir}/scripts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/accounts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/rules ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/core ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/yacd-gh-pages ${system_uid} ${system_gid} 0755 0644
set_perm  ${MODPATH}/service.sh  0  0  0755
set_perm  ${MODPATH}/uninstall.sh  0  0  0755
set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
set_perm  ${MODPATH}/system/bin/ss 0 0 0755
set_perm  ${MODPATH}/system/bin/clash 0 0 6755
set_perm  ${MODPATH}${ca_path}/cacert.pem 0 0 0644
set_perm  ${MODPATH}${dns_path}/resolv.conf 0 0 0755
set_perm  ${clash_data_dir}/accounts/trojan.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/accounts/trojango.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/accounts/vmess.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/rules/game.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/rules/indonesian.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/rules/streaming.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/rules/reject.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/rules/sosmed.yaml ${system_uid} ${system_gid}  0644
set_perm  ${clash_data_dir}/scripts/clash.tproxy 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.tool 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.inotify 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.service 0  0  0755
set_perm  ${clash_data_dir}/scripts/start.sh 0  0  0755
set_perm  ${clash_data_dir}/scripts/clash.config ${system_uid} ${system_gid} 0755
set_perm  ${clash_service_dir}/cfm_service.sh   0  0  0755
