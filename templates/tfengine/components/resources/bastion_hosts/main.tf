{{- /* Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

{{range .bastion_hosts}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 3.0.0"

  name         = "{{.name}}"
  project      = {{- if get $.project "exists" false}} "{{$.project.project_id}}" {{- else}} module.project.project_id {{end}}
  {{- if get $ "use_constants"}}
  zone         = local.constants.compute_region
  {{- else}}
  zone         = "{{get . "compute_region" $.compute_region}}-{{get . "compute_zone" $.compute_zone}}"
  {{- end}}
  {{if has . "network_project_id" -}}
  host_project = "{{.network_project_id}}"
  {{else -}}
  host_project = {{- if get $.project "exists" false}} "{{$.project.project_id}}" {{- else}} module.project.project_id {{end}}
  {{end -}}
  network      = "{{.network}}"
  subnet       = "{{.subnet}}"
  members      = {{hcl .members}}
  {{hclField . "image_family"}}
  {{hclField . "image_project"}}
  {{hclField . "scopes"}}

  {{if $labels := merge (get $ "labels") (get . "labels") -}}
  labels = {
    {{range $k, $v := $labels -}}
    {{$k}} = "{{$v}}"
    {{end -}}
  }
  {{end -}}

  {{- if has . "startup_script"}}
  startup_script = <<EOF
{{.startup_script}}
EOF
  {{end -}}
}
{{end -}}
