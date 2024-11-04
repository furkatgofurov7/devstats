#!/bin/bash
# MERGE_MODE=1 (use merge DBs mode instead of generating data via 'gha2db')
function finish {
    sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
fi
set -o pipefail
> errors.txt
> run.log
GHA2DB_PROJECT=all PG_DB=allprj GHA2DB_LOCAL=1 GHA2DB_MGETC=y structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql allprj -c "create extension if not exists pgcrypto" || exit 2
./devel/db.sh psql allprj -c "create extension if not exists hll" || exit 2
if [ -z "$MERGE_MODE" ]
then
  exclude="kubernetes/api,kubernetes/apiextensions-apiserver,kubernetes/apimachinery,kubernetes/apiserver,kubernetes/client-go,kubernetes/code-generator,kubernetes/kube-aggregator,kubernetes/metrics,kubernetes/sample-apiserver,kubernetes/sample-controller,kubernetes/csi-api,kubernetes/kube-proxy,kubernetes/kube-controller-manager,kubernetes/kube-scheduler,kubernetes/kubelet,kubernetes/sample-cli-plugin"
  exclude="${exclude},k3s-io/klog,k3s-io/containerd,k3s-io/cri-tools,k3s-io/etcd,k3s-io/flannel,k3s-io/go-powershell,k3s-io/kubernetes,k3s-io/nocode"
  args="kubernetes,kubernetes-client,kubernetes-incubator,kubernetes-csi,kubernetes-graveyard,kubernetes-incubator-retired,kubernetes-sig-testing,kubernetes-providers,kubernetes-addons,kubernetes-extensions,kubernetes-federation,kubernetes-security,kubernetes-sigs,kubernetes-sidecars,kubernetes-tools,kubernetes-test,kubernetes-retired,GoogleCloudPlatform/kubernetes"
  args="${args},prometheus,opentracing,fluent,linkerd,BuoyantIO/linkerd,grpc,miekg/coredns,coredns,containerd,docker/containerd,containernetworking,appc/cni,envoyproxy,lyft/envoy,jaegertracing,uber/jaeger,theupdateframework,docker/notary,notaryproject,rook,vitessio,youtube/vitess,nats-io,apcera/nats,apcera/gnatsd,kubevela"
  args="${args},open-policy-agent,spiffe,cloudevents,openeventing,telepresenceio,datawire/telepresence,helm,kubernetes-helm,kubernetes-charts,kubernetes/helm,kubernetes/charts,kubernetes/deployment-manager,kubernetes/application-dm-templates,OpenObservability,RichiH/OpenMetrics,goharbor,vmware/harbor,coreos/etcd,etcd,etcd-io,pingcap/tikv,tikv,buildpacks,tellerops,buildpacks-community"
  args="${args},cortexproject,weaveworks/cortex,weaveworks/prism,weaveworks/frankenstein,buildpack,falcosecurity,draios/falco,dragonflyoss,alibaba/Dragonfly,virtual-kubelet,Virtual-Kubelet,kubeedge,brigadecore,Azure/brigade,kubernetes-incubator/ocid,kubernetes-incubator/cri-o,kubernetes-sigs/cri-o,cri-o,networkservicemesh,NetworkServiceMesh,ligato/networkservicemesh"
  args="${args},open-telemetry,thanos-io,improbable-eng/promlts,improbable-eng/thanos,fluxcd,weaveworks/flux,in-toto,strimzi,EnMasseProject/barnabas,ppatierno/barnabas,ppatierno/kaas,kubevirt,cncf,crosscloudci,cdfoundation,longhorn,chubaofs,cubefs,cubeFS,kedacore,containerfs/containerfs.github.io,containerfilesystem/cfs,containerfilesystem/doc-zh,pixie-io,open-gitops"
  args="${args},tomkerkhove/sample-dotnet-queue-worker,tomkerkhove/sample-dotnet-queue-worker-servicebus-queue,tomkerkhove/sample-dotnet-worker-servicebus-queue,rancher/longhorn,deislabs/smi-spec,deislabs/smi-sdk-go,deislabs/smi-metrics,deislabs/smi-adapter-istio,deislabs/smi-spec.io,servicemeshinterface,argoproj,volcano-sh,cni-genie,keptn,kudobuilder,kumahq,crossplane-contrib"
  args="${args},Huawei-PaaS/CNI-Genie,patras-sdk/kubebuilder-maestro,patras-sdk/maestro,maestrosdk/maestro,maestrosdk/frameworks,cloud-custodian,capitalone/cloud-custodian,dexidp,coreos/dex,litmuschaos,artifacthub,Kong/kuma,Kong/kuma-website,Kong/kuma-demo,Kong/kuma-gui,Kong/kumacut,Kong/docker-kuma,parallaxsecond,docker/pasl,bfenetworks,baidu/bfe,crossplane,crossplaneio,cdk8s-team"
  args="${args},spotify/backstage,wayfair-tremor,metal3-io,deislabs/porter,alibaba/openyurt,awslabs/cdk8s,jetstack/cert-manager,jetstack-experimental/cert-manager,packethost/tinkerbell,openservicemesh,getporter,keylime,backstage,schemahero,openkruise,kruiseio,tinkerbell,pravega,kyverno,cert-manager,k3s-io,gitops-working-group,piraeusdatastore,indeedeng/k8dash,indeedeng/k8dash-website"
  args="${args},yahoo/athenz,alauda/kube-ovn,distribution,kubeovn,AthenZ,openyurtio,Comcast/kuberhealthy,k8gb-io,AbsaOSS/k8gb,AbsaOSS/ohmyglb,tricksterproxy,trickstercache,Comcast/trickster,emissary-ingress,datawire/ambassador,kuberhealthy,WasmEdge,second-state/SSVM,chaosblade-io,alibaba/v6d,alibaba/libvineyard,vmware-tanzu/antrea,v6d-io"
  args="${args},fluid-cloudnative,cheyang/fluid,submariner-io,rancher/submariner,argoproj-labs,kube-vip,alibaba/kubedl,pixie-labs/pixie,pixie-labs/px-dev-website,pixie-labs/pxapi.go,pixie-labs/pixie-docs,pixie-labs/pixie-demos,pixie-labs/pixie-docs,pixie-labs/px.dev,pixie-labs/pixie-blog,pixie-labs/grafana-plugin,oam-dev/kubevela,oam-dev/kubevela.io,oam-dev/kubevela-core-api,oam-dev/velacp"
  args="${args},oam-dev/kubevela-tutorials,layer5io/meshery,layer5io/service-mesh-benchmark-spec,layer5io/meshery-istio,layer5io/meshery-linkerd,layer5io/meshery-octarine,layer5io/meshery-consul,layer5io/meshery-nsm,layer5io/istio-service-mesh-workshop,layer5io/meshery-app-mesh,layer5io/meshery-maesh,layer5io/meshery-kuma,layer5io/meshery-cpx,layer5io/meshery-nsx-sm,layer5io/meshery-adapter-template"
  args="${args},layer5io/meshery.io,layer5io/meshery-tmp,layer5io/service-mesh-performance-specification,layer5io/meshery-tanzu-sm,layer5io/meshery-operator,layer5io/meshery-osm,layer5io/meshery-adapter-kit,layer5io/service-mesh-performance,layer5io/meshery-nginx-sm,layer5io/advanced-istio-service-mesh-workshop,layer5io/meshery-adapter-library,layer5io/linkerd-service-mesh-workshop"
  args="${args},layer5io/service-mesh-labs,layer5io/meshery-traefik-mesh,layer5io/mesheryctl-smi-conformance-action,plounder-app/kube-vip,service-mesh-performance,deislabs/krustlet,oras-project,deislabs/oras,shizhMSFT/oras,wasmCloud,wascc,wascaruntime,waxosuit,deislabs/akri,metallb,danderson/metallb,google/metallb,karmada-io,alibaba/inclavare-containers,superedge,cilium,noironetworks/cilium-net"
  args="${args},projectcontour,operator-framework,heptio/contour,chaos-mesh,serverlessworkflow,pingcap/chaos-mesh,cncf/wg-serverless-workflow,skooner-k8s,antrea-io,project-akri,dapr,kubesphere/openelb,kubesphere/porterlb,kubesphere/porter,open-cluster-management-io,Azure/vscode-kubernetes-tools,vscode-kubernetes-tools,nocalhost,kubearmor,accuknox/KubeArmor,k8up-io,vshn/k8up,kube-rs,clux/kube-rs,kubedl-io"
  args="${args},clux/kubernetes-rust,devfile,che-incubator/devworkspace-api,meshery,knative,knative-sandbox,FabEdge,confidential-containers,SpectralOps/teller,SpectralOps/helm-teller,SpectralOps/setup-teller-action,OpenFunction,sealerio,alibaba/sealer,clusterpedia-io,aeraki-mesh,aeraki-framework,opencurve,open-feature,openfeatureflags,kubewarden,chimera-kube,devstream-io,merico-dev/stream,merico-dev/OpenStream"
  args="${args},hexa-org,konveyor,fusor/mig-operator,G-Research/armada,external-secrets,krustlet,Serverless-Devs,ServerlessTool,ContainerSSH,janoszen/ContainerSSH,janoszen/containerssh,openfga,weaveworks/kured,lima-vm,AkihiroSuda/lima,vmware-tanzu/carvel,vmware-tanzu/carvel-kapp-controller,vmware-tanzu/carvel-kapp,vmware-tanzu/carvel-ytt,vmware-tanzu/carvel-imgpkg,vmware-tanzu/carvel-kbld,armadaproject"
  args="${args},vmware-tanzu/carvel-vendir,vmware-tanzu/carvel-kwt,vmware-tanzu/carvel-secretgen-controller,kubereboot,istio,inclavare-containers,merbridge,kebe7jun/mepf,kebe7jun/mebpf,devspace-cloud,covexo,project-zot,anuvu/zot,paralus,carina-io,ko-build,google/ko,werf,flant/werf,flant/dapp,flant,dapper,kubescape,armosec/kubescape,openelb,carvel-dev,opencost,inspektor-gadget,clusternet,keycloak"
  args="${args},kinvolk/inspektor-gadget,clastix/capsule,clastix/capsule-proxy,clastix/capsule-addon-rancher,clastix/capsule-community,clastix/capsule-addon-cloudcasa,clastix/capsule-k8s-charm,clastix/clastix/capsule-lens-extension,clastix/capsule-helm-chart,clastix/flux2-capsule-multi-tenancy,clastix/capsule-ns-filter,clastix/Capsule,clastix/ckd-capsule-app,cncf/sig-app-delivery,cncf/tag-app-delivery"
  args="${args},mozilla/sops,mozilla/sotp,mozilla-services/sops,headlamp-k8s,kinvolk/headlamp,slimtoolkit,docker-slim,cloudimmunity/docker-slim,sustainable-computing-io,pipe-cd,Azure/eraser,xline-kv,datenlord/Xline,hwameistor,GoogleContainerTools/kpt,microcks,kubeclipper,kubeclipper-labs,kubeflow,google/kubeflow,getsops,eraser-dev,knative-extensions,project-copacetic,kube-logging,kanisterio,kcp-dev,kcl-lang"
  args="${args},banzaicloud/logging-operator,projectcapsule,kube-burner,kuasar-io,redhat-chaos,kubestellar,megaease,spidernet-io,k8sgpt-ai,cloud-bulldozer/kube-burner,cloud-bulldozer/rosa-burner,chaos-kubox,cloud-bulldozer/krkn,cloud-bulldozer/kraken,openshift-scale/kraken,KubeStellar,kcp-dev/edge-mc,kptdev,devspace-sh,loft-sh/devspace,krkn-chaos,OpenMetrics,openmetrics"
  args="${args},kubeslice,connectrpc,bufbuild/connect-go,bufbuild/rerpc,kairos-io,c3os-io,mudler/c3os,kubean-io,koordinator-sh,radius-project,easegress-io,bank-vaults,banzaicloud/bank-vaults,banzaicloud/vault-dogsbody,runatlantis,atlantisnorth/atlantis,project-stacker,anuvu/stacker,oscal-compass,IBM/compliance-trestle,Kuadrant,3scale-labs/authorino,openGemini,score-spec,bpfman,bpfd-dev,redhat-et/bpfd"
  args="${args},loxilb-io,lyft/cartography,perses,ratify-project,deislabs/ratify,deislabs/ratify-web,deislabs/ratify-action,Project-HAMi,shipwright-io,redhat-developer/build,redhat-developer/buildv2,redhat-developer/buildv2-operator,flatcar,flatcar-linux,kinvolk/Flatcar,kinvolk/flatcar-scripts,kinvolk/mantle,k8snetworkplumbingwg/kubemacpool,k8snetworkplumbingwg/multi-networkpolicy-iptables"
  args="${args},k8snetworkplumbingwg/sriov-network-operator,nmstate/kubernetes-nmstate,KusionStack,cartography-cncf,cncf-tags,youki-dev,containers/youki,utam0k/youki,Azure/kaito,kaito-project,openebs,sermant-io,huaweicloud/Sermant,huaweicloud/java-mesh,huaweicloud/JavaMesh,kmesh-net,ovn-org,openswitch/ovn-kubernetes"
  GHA2DB_EXCLUDE_REPOS=$exclude GHA2DB_PROJECT=all PG_DB=allprj GHA2DB_LOCAL=1 gha2db 2015-01-01 0 today now "${args}" 2>>errors.txt | tee -a run.log || exit 3
  args="GoogleCloudPlatform/kubernetes,kubernetes,kubernetes-client,kubernetes-csi,prometheus/prometheus,fluent,rocket,theupdateframework,tuf,vitessio,youtube/vitess,nats-io,apcera/nats,apcera/gnatsd,etcd,keycloak"
  GHA2DB_PROJECT=all PG_DB=allprj GHA2DB_LOCAL=1 GHA2DB_OLDFMT=1 GHA2DB_EXACT=1 gha2db 2014-01-02 0 2014-12-31 23 "${args}" 2>>errors.txt | tee -a run.log || exit 4
else
  GHA2DB_INPUT_DBS="gha,prometheus,opentracing,fluentd,linkerd,grpc,coredns,containerd,cni,envoy,jaeger,notary,tuf,rook,vitess,nats,cncf,opa,spiffe,spire,cloudevents,telepresence,helm,harbor,etcd,tikv,cortex,buildpacks,falco,dragonfly,virtualkubelet,kubeedge,brigade,crio,networkservicemesh,opentelemetry,thanos,flux,intoto,strimzi,kubevirt,longhorn,chubaofs,kedacore,servicemeshinterface,argoproj,volcano,cnigenie,keptn,kudo,cloudcustodian,dex,litmuschaos,artifacthub,kuma,parsec,bfe,crossplane,contour,operatorframework,chaosmesh,serverlessworkflow,k3s,backstage,tremor,metal3,porter,openyurt,openservicemesh,keylime,schemahero,cdk8s,certmanager,openkruise,tinkerbell,pravega,kyverno,gitopswg,piraeus,k8dash,athenz,kubeovn,distribution,kuberhealthy,k8gb,trickster,emissaryingress,wasmedge,chaosblade,vineyard,antrea,fluid,submariner,pixie,meshery,servicemeshperformance,kubevela,kubevip,kubedl,krustlet,oras,wasmcloud,akri,metallb,karmada,inclavarecontainers,superedge,cilium,dapr,openelb,openclustermanagement,vscodek8stools,nocalhost,kubearmor,k8up,kubers,devfile,knative,fabedge,confidentialcontainers,openfunction,teller,sealer,clusterpedia,opencost,aerakimesh,curve,openfeature,kubewarden,devstream,hexapolicyorchestrator,konveyor,armada,externalsecretsoperator,serverlessdevs,containerssh,openfga,kured,carvel,lima,istio,merbridge,devspace,capsule,zot,paralus,carina,ko,opcr,werf,kubescape,inspektorgadget,clusternet,keycloak,sops,headlamp,slimtoolkit,kepler,pipecd,eraser,xline,hwameistor,kpt,microcks,kubeclipper,kubeflow,copacetic,loggingoperator,kanister,kcp,kcl,kubeburner,kuasar,krknchaos,kubestellar,easegress,spiderpool,k8sgpt,kubeslice,connect,kairos,kubean,koordinator,radius,bankvaults,atlantis,stacker,trestlegrc,kuadrant,opengemini,score,bpfman,loxilb,cartography,perses,ratify,hami,shipwrightcncf,flatcar,kusionstack,youki,kaito,openebs,sermant,kmesh,ovnkubernetes" GHA2DB_OUTPUT_DB="allprj" merge_dbs || exit 2
fi
GHA2DB_PROJECT=all PG_DB=allprj GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 3
GHA2DB_PROJECT=all PG_DB=allprj ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 4
GHA2DB_PROJECT=all PG_DB=allprj ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=all PG_DB=allprj ./shared/import_affs.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=all PG_DB=allprj ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=all PG_DB=allprj GHA2DB_LOCAL=1 GHA2DB_EXCLUDE_VARS="projects_health_partial_html" vars || exit 8
./devel/ro_user_grants.sh allprj || exit 10
./devel/psql_user_grants.sh devstats_team allprj || exit 11
