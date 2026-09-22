/*
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
*/

package main

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/kubewarden/network-enforcer/internal/certsource"
)

func TestIstioTLSCertDir(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name       string
		tlsMode    string
		tlsCertDir string
		wantDir    string
		wantErr    string
	}{
		{
			name:       "insecure allows empty cert dir",
			tlsMode:    string(certsource.ModeInsecure),
			tlsCertDir: "",
			wantDir:    "",
		},
		{
			name:       "issuer requires cert dir",
			tlsMode:    string(certsource.ModeIssuer),
			tlsCertDir: "",
			wantErr:    `istio provider TLS mode "issuer" requires --provider-tls-cert-dir`,
		},
		{
			name:       "issuer with cert dir",
			tlsMode:    string(certsource.ModeIssuer),
			tlsCertDir: "/etc/provider/certs",
			wantDir:    "/etc/provider/certs",
		},
		{
			name:       "existingSecret requires cert dir",
			tlsMode:    string(certsource.ModeExistingSecret),
			tlsCertDir: "",
			wantErr:    `istio provider TLS mode "existingSecret" requires --provider-tls-cert-dir`,
		},
		{
			name:       "existingSecret with cert dir",
			tlsMode:    string(certsource.ModeExistingSecret),
			tlsCertDir: "/etc/provider/certs",
			wantDir:    "/etc/provider/certs",
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			got, err := istioTLSCertDir(tc.tlsMode, tc.tlsCertDir)
			if tc.wantErr != "" {
				require.EqualError(t, err, tc.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tc.wantDir, got)
		})
	}
}
