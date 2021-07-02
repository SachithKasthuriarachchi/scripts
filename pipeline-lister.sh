#!/bin/bash

function getProjectsList() {
  project_list=()
  values=$(echo "$1" | jq '.value')
  for row in $(echo "${values}" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${row}" | base64 --decode | jq -r '.name'
    }
    project_name=$(_jq)
    project_list+=("${project_name}")
  done
  for value in "${project_list[@]}"; do
    echo "$value"
  done
}
echo -e "Log in with Azure!"
#az login --allow-no-subscriptions
read -p "Enter organization (ex: https://dev.azure.com/organization): " org

##Project List
projects=$(az devops project list --org "${org}" 2>/dev/null)
echo -e "\nProject List\n"
getProjectsList "${projects}"
echo -e "\n===================\n"

pipes="["
for p in "${project_list[@]}"; do
  folders=$(az pipelines folder list --org "${org}" --project "${p}" 2>/dev/null)
  paths=()
  for folder in $(echo "${folders}" | jq -r '.[] | @base64'); do
    getPaths() {
      echo "${folder}" | base64 --decode | jq -r '.path'
    }
    path=$(getPaths)
    paths+=("${path}")
  done
  echo -e "Listing pipelines in ${p}"
  for temp_path in "${paths[@]}"; do
    pipelines=$(az pipelines list --org "${org}" --project ${p} \
      --folder-path "${temp_path}" 2>/dev/null)
    for pipe in $(echo "${pipelines}" | jq -r '.[] | @base64'); do
      getPipeName() {
        echo "${pipe}" | base64 --decode | jq -r '.name'
      }
      pipe_name=$(getPipeName)
      temp_pipe=$(az pipelines show --org "${org}" --project ${p} \
        --folder-path "${temp_path}" \
        --name "${pipe_name}" 2>/dev/null)
      yamlFileName=$(echo "${temp_pipe}" | jq '.process .yamlFilename')
      manageURL=$(echo "${temp_pipe}" | jq '.repository .properties .manageUrl')
      branch=$(echo "${temp_pipe}" | jq '.repository .properties .defaultBranch')
      pipes+="{\"name\":\"${pipe_name}\", $(
      )\"yamlFileName\":${yamlFileName}, $(
      )\"manageURL\":${manageURL}, $(
      )\"branch\":${branch}},"
    done
  done
done
pipes=${pipes:0:${#pipes}-1}
pipes+="]"

echo "${pipes}" | jq '.' >pipes.json
