#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Cluster map: keyed by alias, value is profile|name|role-arn
# All fields are required. Use this to explicitly configure clusters instead of auto-discovery.
declare -A CLUSTER_MAP=(
    ["bgdi/dev"]="swisstopo-bgdi-dev|dev|arn:aws:iam::839910802816:role/kubernetes-devs-dev"
    ["bgdi/int"]="swisstopo-bgdi|int|arn:aws:iam::993448060988:role/kubernetes-admins-int"
    ["bgdi/prod-green"]="swisstopo-bgdi|prod-green|arn:aws:iam::993448060988:role/kubernetes-admins-prod-green"
)

usage() {
    echo "Usage: $0 [--region REGION] [--profile PROFILE]"
    echo ""
    echo "Discover and update kubeconfig for all EKS clusters across swisstopo AWS profiles."
    echo ""
    echo "Options:"
    echo "  --region REGION    AWS region to scan (default: eu-central-1)"
    echo "  --profile PROFILE  Only scan this AWS profile (default: all swisstopo-* profiles)"
    exit 1
}

ensure_sso_login() {
    local profile="$1"
    if ! AWS_PROFILE="$profile" aws sts get-caller-identity &>/dev/null; then
        echo -e "${YELLOW}SSO session expired for profile '$profile', logging in...${NC}"
        aws sso login --profile "$profile"
    fi
}

region="eu-central-1"
filter_profile=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        --region) region="$2"; shift 2 ;;
        --profile) filter_profile="$2"; shift 2 ;;
        *) echo -e "${RED}Unknown argument: $1${NC}"; usage ;;
    esac
done

if [[ -n "$filter_profile" ]]; then
    profiles=("$filter_profile")
else
    mapfile -t profiles < <(aws configure list-profiles | grep '^swisstopo' | sort)
fi

echo -e "${YELLOW}Scanning ${#profiles[@]} profiles in region $region...${NC}"

update_kubeconfig() {
    local eks_profile="$1" cluster_name="$2" alias="$3" role_arn="$4"
    local role_args=()
    [[ -n "$role_arn" ]] && role_args=(--role-arn "$role_arn")
    AWS_PROFILE="$eks_profile" aws eks update-kubeconfig \
        --region "$region" \
        --name "$cluster_name" \
        --kubeconfig "$HOME/.kube/config" \
        --alias "$alias" \
        "${role_args[@]}"
}

found=0
failed=0

# Process explicit CLUSTER_MAP entries first
for alias in "${!CLUSTER_MAP[@]}"; do
    IFS='|' read -r eks_profile cluster_name role_arn <<< "${CLUSTER_MAP[$alias]}"
    ensure_sso_login "$eks_profile"
    account_id=$(AWS_PROFILE="$eks_profile" aws sts get-caller-identity --query Account --output text 2>/dev/null)
    local_arn="arn:aws:eks:${region}:${account_id}:cluster/${cluster_name}"
    echo -e "  ${GREEN}✓${NC} $cluster_name  ($local_arn)  alias=$alias${role_arn:+  role=$role_arn}"
    update_kubeconfig "$eks_profile" "$cluster_name" "$alias" "$role_arn"
    (( found++ )) || true
done

# Build set of already-handled cluster names to skip during auto-discovery
declare -A mapped_clusters=()
for alias in "${!CLUSTER_MAP[@]}"; do
    IFS='|' read -r _ cluster_name _ <<< "${CLUSTER_MAP[$alias]}"
    mapped_clusters["$cluster_name"]=1
done

# Auto-discover remaining clusters from profiles
for profile in "${profiles[@]}"; do
    echo -e "  ${YELLOW}→${NC} $profile"
    ensure_sso_login "$profile"

    clusters_json=$(AWS_PROFILE="$profile" aws eks list-clusters --region "$region" --output json 2>/dev/null) || {
        echo -e "    ${RED}✗${NC} Failed to list clusters (check permissions)"
        failed=1
        continue
    }

    mapfile -t cluster_names < <(echo "$clusters_json" | grep -oP '(?<=")\S+(?=")' | grep -v clusters)

    if [[ ${#cluster_names[@]} -eq 0 ]]; then
        echo -e "    (no clusters)"
        continue
    fi

    account_id=$(AWS_PROFILE="$profile" aws sts get-caller-identity --query Account --output text 2>/dev/null)

    for cluster in "${cluster_names[@]}"; do
        [[ -n "${mapped_clusters[$cluster]+_}" ]] && continue

        local_arn="arn:aws:eks:${region}:${account_id}:cluster/${cluster}"
        alias="${profile#swisstopo-}/${cluster}"
        echo -e "    ${GREEN}✓${NC} $cluster  ($local_arn)  alias=$alias"
        update_kubeconfig "$profile" "$cluster" "$alias" ""
        (( found++ )) || true
    done
done

echo ""
if [[ $found -gt 0 ]]; then
    echo -e "${GREEN}Discovered and updated $found cluster(s).${NC}"
else
    echo -e "${YELLOW}No clusters found.${NC}"
fi

[[ $failed -eq 0 ]]
