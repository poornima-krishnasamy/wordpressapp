#!/bin/bash

ENV_INFO_PREFIX="${ENV_INFO_PREFIX:-KUBE_ENV}"
echo ${ENV_INFO_PREFIX}
for e in $(env | grep "${ENV_INFO_PREFIX}" | sed -E 's/^'"${ENV_INFO_PREFIX}"'_([^_]+)_.+$/\1/g' | sort | uniq); do
  echo ">>> detected environment information '${e}'"
  _ev="${ENV_INFO_PREFIX}_${e}_NAME"
  [ -z "${!_ev}" ] && echo ">>> missing ${_ev}, cannot configure environment '${e}'" && continue
  _ename="${!_ev}"
  _ehost="https://api.${!_ev}"
  _ev="${ENV_INFO_PREFIX}_${e}_NAMESPACE"
  [ -z "${!_ev}" ] && echo ">>> missing ${_ev}, cannot configure environment '${e}'" && continue
  _enamespace="${!_ev}"
  _ev="${ENV_INFO_PREFIX}_${e}_CACERT"
  [ -z "${!_ev}" ] && echo ">>> missing ${_ev}, cannot configure environment '${e}'" && continue
  _ecacert=".${e}_ca.crt"
  echo -n "${!_ev}" | base64 -D > "${_ecacert}"
  _ev="${ENV_INFO_PREFIX}_${e}_TOKEN"
  [ -z "${!_ev}" ] && echo ">>> missing ${_ev}, cannot configure environment '${e}'" && continue
  _etoken="${!_ev}"

  _cname="$(echo -n ${e} | tr '[:upper:]' '[:lower:]')"
  kubectl config set-cluster "${_ename}" \
    --certificate-authority="${_ecacert}" \
    --server="${_ehost}"
  kubectl config set-credentials "${_cname}" \
    --token="${_etoken}"
  kubectl config set-context "${_cname}" \
    --cluster="${_ename}" \
    --user="${_cname}" \
    --namespace="${_enamespace}"

  echo ">>> configured environment '${e}'"
done

echo ">>> kubernetes auth setup is complete"
