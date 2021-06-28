# ----------------------------------------------------------------
# set custom limits
# ----------------------------------------------------------------

cat <<EOF >/etc/security/limits.d/99-techbytes.conf
# custom limits for techbyte sample demo

*       soft    nofile          10000
*       hard    nofile          16384
EOF