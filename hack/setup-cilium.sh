#!/usr/bin/env bash

set -eu

CILIUM_VERSION="${CILIUM_VERSION:-1.20.0}"
CILIUM_NAMESPACE="kube-system"

# HUBBLE_RELAY_TLS selects how the Hubble PKI is produced:
#   helm        Cilium generates it; the CA key stays in the cilium-ca Secret, so issuer mode cannot apply.
#   certmanager cert-manager issues it, so issuer mode works.
#   off         Relay serves plaintext on :80; install the chart with tls.mode=insecure.
HUBBLE_RELAY_TLS="${HUBBLE_RELAY_TLS:-helm}"
HUBBLE_CERT_MANAGER_ISSUER_NAME="${HUBBLE_CERT_MANAGER_ISSUER_NAME:-hubble-ca}"
HUBBLE_CERT_MANAGER_ISSUER_KIND="${HUBBLE_CERT_MANAGER_ISSUER_KIND:-ClusterIssuer}"
HUBBLE_CERT_MANAGER_ISSUER_GROUP="${HUBBLE_CERT_MANAGER_ISSUER_GROUP:-cert-manager.io}"

# policyDenyResponse=icmp makes cilium answer denied egress traffic with an ICMP
# error instead of silently dropping it.
helm_args=(
  --set hubble.enabled=true
  --set hubble.relay.enabled=true
  --set policyDenyResponse=icmp
)

case "$HUBBLE_RELAY_TLS" in
off)
  helm_args+=(--set hubble.relay.tls.server.enabled=false)
  ;;
helm)
  # mtls=true makes relay verify client certificates against the Hubble CA.
  helm_args+=(
    --set hubble.relay.tls.server.enabled=true
    --set hubble.relay.tls.server.mtls=true
  )
  ;;
certmanager)
  helm_args+=(
    --set hubble.relay.tls.server.enabled=true
    --set hubble.relay.tls.server.mtls=true
    --set hubble.tls.auto.enabled=true
    --set hubble.tls.auto.method=certmanager
    --set "hubble.tls.auto.certManagerIssuerRef.name=$HUBBLE_CERT_MANAGER_ISSUER_NAME"
    --set "hubble.tls.auto.certManagerIssuerRef.kind=$HUBBLE_CERT_MANAGER_ISSUER_KIND"
    --set "hubble.tls.auto.certManagerIssuerRef.group=$HUBBLE_CERT_MANAGER_ISSUER_GROUP"
  )
  ;;
*)
  printf "\n- ❌ HUBBLE_RELAY_TLS must be helm, certmanager, or off (got %q)\n" "$HUBBLE_RELAY_TLS" >&2
  exit 1
  ;;
esac

helm repo add cilium https://helm.cilium.io/
helm repo update

printf "\n- 🚀 Install cilium with Hubble and Hubble Relay (relay TLS: %s):\n" "$HUBBLE_RELAY_TLS"
helm upgrade --install cilium cilium/cilium \
  --version "$CILIUM_VERSION" \
  --namespace "$CILIUM_NAMESPACE" \
  --wait --timeout 10m \
  "${helm_args[@]}"

printf "\n- 🚀 Wait for cilium and Hubble Relay to be ready:\n"
kubectl rollout status daemonset/cilium -n "$CILIUM_NAMESPACE" --timeout=300s
kubectl rollout status deployment/cilium-operator -n "$CILIUM_NAMESPACE" --timeout=300s
kubectl rollout status deployment/hubble-relay -n "$CILIUM_NAMESPACE" --timeout=300s
