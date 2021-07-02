import json


def get_remaining_pipelines(deletable, v2):
    deletable_pipes = json.loads(deletable.read())
    all_pipes = json.loads(v2.read())

    remaining_pipes = []
    for pipe in all_pipes:
        if pipe not in deletable_pipes:
            remaining_pipes.append(pipe)
    return remaining_pipes

deletable_pipes = open("deletable.json","r")
all_pipes = open("v2.json", "r")
remaining = get_remaining_pipelines(deletable_pipes, all_pipes)
f = open("remaining.json","w")
f.write(json.dumps(remaining, indent=4, sort_keys=False))
f.close()
