import json


def getv2files(file):
    v2files = []
    data = json.loads(file.read())
    print(data)
    for entry in data:
        if (not (entry['yamlFileName'] is None)) and "v2" in entry['yamlFileName']:
            v2files.append(entry)
    v2_json = json.dumps(v2files, indent=4, sort_keys=True)
    f = open('v2.json', 'w')
    f.write(v2_json)
    return


fp = open('pipes.json', 'r')
getv2files(fp)
