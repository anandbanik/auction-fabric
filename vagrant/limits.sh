# ----------------------------------------------------------------
# set custom limits
# ----------------------------------------------------------------

cat <<EOF >/etc/security/limits.d/99-fabric.conf
# custom limits for fabric workshop

*       soft    nofile          10000
*       hard    nofile          16384
EOF