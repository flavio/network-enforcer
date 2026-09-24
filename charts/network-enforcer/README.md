# network-enforcer

> [!WARNING]
> This repo is still under active development.
> At the moment is more a research project than a production-ready solution.

Network Enforcer is a Kubernetes-focused project that helps teams move from permissive networking to policy-driven cluster security.

It observes real network flows from running workloads, correlates traffic patterns, and produces `WorkloadNetworkPolicyProposal` resources that describe suggested ingress/egress rules. These proposals can be reviewed and validated before they are enforced, so teams keep control while reducing trial-and-error.

The project is built around a Kubernetes controller that manages the proposal and policy lifecycle. The controller scrapes flow telemetry from the configured data-plane provider (Istio ambient via ztunnel and fluent-bit, Calico Goldmane, or Cilium Hubble Relay).

The goal is to reduce manual NetworkPolicy authoring effort while improving visibility, consistency, and confidence in workload-to-workload communication boundaries.

## Documentation

The full documentation is available at
[docs.kubewarden.io/network-enforcer](https://docs.kubewarden.io/network-enforcer/latest/en/introduction.html).

- [Quick Start](https://docs.kubewarden.io/network-enforcer/latest/en/installation/quickstart.html)
  — deploy Network Enforcer and walk through the learn/monitor/protect workflow.
- [Compatibility](https://docs.kubewarden.io/network-enforcer/latest/en/compatibility.html)
  — provider and platform requirements.
- [Phases: learn, monitor, protect](https://docs.kubewarden.io/network-enforcer/latest/en/phases.html)
  — understand the learn, monitor and protect phases in detail.

## License

Copyright 2026.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
