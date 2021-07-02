import json


def getdeletablefiles(oldpipelines, newpipelines):
    deletables = []
    new_files = json.loads(newpipelines.read())
    old_files = json.loads(oldpipelines.read())

    for pipeline in new_files:
        new_yaml = pipeline['yamlFileName']
        new_repo = pipeline['manageURL']
        new_branch = pipeline['branch']

        if not (new_yaml is None):
            if "yaml" in new_yaml:
                new_yaml = new_yaml[:-8]
            elif "yml" in new_yaml:
                new_yaml = new_yaml[:-7]
            for entry in old_files:
                old_yaml = entry['yamlFileName']
                old_repo = entry['manageURL']
                old_branch = entry['branch']
                if (not (old_yaml is None)) and (
                        new_yaml in old_yaml) and old_repo == new_repo and old_branch == new_branch:
                    break
            else:
                deletables.append(pipeline)

    return deletables


v2_pipelines = open('v2.json', 'r')
old_pipelines = open('pipes.json', 'r')
de = getdeletablefiles(old_pipelines, v2_pipelines)
f = open('deletable.json', 'w')
f.write(json.dumps(de, indent=4, sort_keys=False))
f.close()
