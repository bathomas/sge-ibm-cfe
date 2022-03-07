#!/bin/bash
# /usr/local/bin/configure-sge.sh
SGEROOT=/opt/sge
SGECLUSTERDIR=${SGEROOT}/default

if [ ! -e "${SGECLUSTERDIR}" ]; then
  echo "Installing SGE..."
  cd ${SGEROOT}
  ${SGEROOT}/inst_sge -x -m -auto /opt/sge/util/install_modules/inst_sge_ibm-cloud.conf
fi

source ${SGECLUSTERDIR}/common/settings.sh

# Checking qmaster
qping -info $HOSTNAME 6444 qmaster 1 > /dev/null
QMASTERSTATUS=$?

if [ "${QMASTERSTATUS}" -ne 0 ]; then
  echo "Trying to start qmaster..."
  ${SGECLUSTERDIR}/common/sgemaster
  qping -info $HOSTNAME 6444 qmaster 1 > /dev/null
  QMASTERSTATUS=$?
fi

echo qmaster status $QMASTERSTATUS

# Checking execd
qping -info $HOSTNAME 6445 execd 1 > /dev/null
EXECDSTATUS=$?

if [ "${EXECDSTATUS}" -ne 0 ]; then
  echo "Trying to start qmaster..."
  ${SGECLUSTERDIR}/common/sgeexecd
  qping -info $HOSTNAME 6445 execd 1 > /dev/null
  EXECDSTATUS=$?
fi

echo execd status $EXECDSTATUS

if [ "${QMASTERSTATUS}" -ne 0 ] || [ "${EXECDSTATUS}" -ne 0 ]; then
  # Qmaster or execd failed or not ready yet.
  exit 1
fi

exit 0