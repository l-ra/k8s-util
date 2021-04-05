#######################################################
# Takes esigner360 chart and repository index 
# finds newest version in the repository
# iterates throu dependencies and if there is newer dependency, 
# it is updated
#######################################################

from requests.models import HTTPBasicAuth
import yaml
import os
import requests

# returns extended semver string to compare versions simply
def semVer2Number(semVer):
    split = semVer.split(".")
    ret = ""
    for ver in split:
        ret = ret + "." + ("0000000000000000000000" + ver)[-20:]
    return ret

##########################
SEMVER_MAJOR=0
SEMVER_MINOR=1
SEMVER_PATCH=2
def incSemVer(part,semVer):
    semVerNum = list(map(lambda s: int(s), semVer.split(".")))
    semVerNum[part]=semVerNum[part]+1
    return ".".join(list(map(lambda n:str(n), semVerNum)))

##########################
def maxChartEntry(chartVersion):
    return {
                "extendedVer": semVer2Number(chartVersion["version"]),
                "realVer": chartVersion["version"],
                "chart": chartVersion
            }

##########################
def getHighestVersionsFormRepo(repoIndex):
    maxChartVer = {}
    for chartName, chart in repoIndex["entries"].items():
        #print(chartName)
        for chartVersion in chart:
            # initialize at first chart encounter
            if not chartName in maxChartVer:
                maxChartVer[chartName] = maxChartEntry(chartVersion)
            # update if version greater
            if semVer2Number(chartVersion["version"]) > maxChartVer[chartName]["extendedVer"]:
                maxChartVer[chartName] = maxChartEntry(chartVersion)
    return maxChartVer

##########################
def loadRepoIndex(helmRepoUrl, helmRepoUser, helmRepoPwd):
    repoIndexRes = requests.get(helmRepoUrl+"/index.yaml",
                    auth=HTTPBasicAuth(helmRepoUser, helmRepoPwd), verify=False)
    repoIndex = yaml.load(repoIndexRes.text, Loader = yaml.FullLoader)
    return repoIndex

##########################
def loadChart():
    with open("Chart.yaml") as f:
        return yaml.load(f, Loader=yaml.FullLoader)

##### END DEFs ########

helmRepoUrl = os.environ["HELM_REPO_URL"]
helmRepoUser = os.environ["HELM_REPO_USER"]
helmRepoPwd = os.environ["HELM_REPO_PWD"]

# load repo index
repoIndex = loadRepoIndex(helmRepoUrl, helmRepoUser, helmRepoPwd)
maxChartVer = getHighestVersionsFormRepo(repoIndex)
esigner360Ver = maxChartVer["esigner360"]["chart"]["version"]

chart = loadChart()
updated = False

for idx, dep in enumerate(chart["dependencies"]):
    depName=dep["name"]
    depVer=dep["version"]
    maxDepVer = maxChartVer[depName]["chart"]["version"]
    if semVer2Number(depVer) < semVer2Number(maxDepVer):
        print(f"upgrading dependency {depName} {depVer} -> {maxDepVer}")
        chart["dependencies"][idx]["version"] = maxDepVer
        updated = True

if updated:
    oldChartVer = chart["version"]
    newChartVer = incSemVer(SEMVER_PATCH, chart["version"])
    print(f"updating chart version {oldChartVer} -> {newChartVer}")
    chart["version"] = newChartVer

with open("Chart.yaml","w") as f:
    yaml.dump(chart,f,indent=2)
