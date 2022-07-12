# test openeo for R with openeo backend
# https://docs.openeo.cloud/getting-started/r/

# First sign up as "trial" user, Mark has one as of 12/7/22

library(openeo)
con = connect(host = "https://openeo.cloud")

## Collections ####--------------------------------------------------------------

collections = list_collections()

# print an overview of the available collections (printed as data.frame or tibble)
print(collections)

# to print more of the reduced overview metadata
print(collections$SENTINEL1_GRD)

# Dictionary of the full metadata of the "SENTINEL1_GRD" collection (dict)
s2 = describe_collection("SENTINEL1_GRD") # or use the collection entry from the list, e.g. collections$SENTINEL1_GRD
print(s2)

# with RStudio the metadata can also be nicely rendere    d as a web page
collection_viewer(x="SENTINEL1_GRD")

## Processes ####-----------------------------------------------------------------

# List of available openEO processes with full metadata
processes = list_processes()

# List of available openEO processes by identifiers (string)
print(names(processes))

# print metadata of the process with ID "load_collection"
print(processes$load_collection)

#  processes can also be rendered as a web page in the viewer panel, if RStudio is used
process_viewer(processes)

## Authentication ####------------------------------------------------------------

login() #is this once per device?

## Creating a (user-defined) process ##--------------------------------------------

p = processes()

datacube = p$load_collection(
  id = "SENTINEL1_GRD",
  spatial_extent=list(west = 16.06, south = 48.06, east = 16.65, north = 48.35), # This is Vienna and surrounds
  temporal_extent=c("2017-03-01", "2017-04-01"),
  bands=c("VV", "VH")
)

min_reducer = function(data,context) { 
  return(p$min(data = data))
}

reduced = p$reduce_dimension(data = datacube, reducer = min_reducer, dimension="t")


formats = list_file_formats()

result = p$save_result(data = reduced, format = formats$output$GTIFF)

## Batch Job Management ####--------------------------------------------------------

job = create_job(graph=result, title = "Example Title")

start_job(job = job)

# If you want to use an interface for your batch jobs (or other resources) that is easier to use, 
# you can also open the openEO Platform Editor (opens new window)
# https://editor.openeo.cloud/

# editor suggests this job requires 4 hours of cpu?


jobs = list_jobs()
jobs # printed as a tibble or data.frame, but the object is a list

# or use the job id (in this example 'cZ2ND0Z5nhBFNQFq') as index to get a particular job overview
jobs$"vito-j-c5a4454f7fed4b2698c352c151d9d563"

# alternatively request detailed information about the job
describe_job(job = job)

# list the processed results
list_results(job = job)

# download all the files into a folder on the file system
download_results(job = "vito-j-c5a4454f7fed4b2698c352c151d9d563", folder = "openeo_results")


