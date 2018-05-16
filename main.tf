
## Step #1:  load the item cache, this will make any cache-valid
## items available under their item name, and others unavailable
## For example:
##    {
##      "item1": "ValidCachedItem1",
##      // Item2 is invalid or missing
##      "item3": "ValidCachedItem3"
##    }
data "external" "item_cache" {

  ## Here we compute the CLI to execute, as an array of elements;
  ## since we want to selectively include or exclude some of the
  ## elements based on input variables, we assemble them by first
  ## defining a single string of all the elements then using the
  ## split function to split on a token that separates them ('#')
  ##
  ## The final list of CLI elements to execute is as follows:
  ##    pwsh
  ##    Get-TFCache.ps1
  ##    <cache_root>
  ##    [cache_expires?]
  ##

  program = ["${split("#",
    "pwsh#${path.module}/res/Get-TFCache.ps1#${var.cache_root}${
      var.cache_expires <= 0
        ? ""
        : "#-ExpireSecs#${var.cache_expires}"}")}"]
}

## Step #2:  for each cachable item, we define the actual data
## source that would be used to resolve the item value for the
## first time, or if the cache time is expired, making sure to
## include a "count" property that resolves to 0 or 1 based on
## whether the item is included in the resolved cache up above
data "aws_ami" "item_ds" {
  count = "${lookup(data.external.item_cache.result, var.cache_key, "") == "" ? 1 : 0}"

  most_recent      = "${var.most_recent}"
  executable_users = "${var.executable_users}"
  filter           = "${var.filters}"
  owners           = "${var.owners}"
  name_regex       = "${var.name_regex}"
}

## Step #3:  for each cachable item, compute the effective
## value, either from the cache results or the data source
data "null_data_source" "item_value" {
  inputs = {
    _is_cached = "${lookup(data.external.item_cache.result, var.cache_key, "") == ""
      ? false
      : true
    }"
    token = "${lookup(data.external.item_cache.result, var.cache_key, "") == ""
      ? timestamp()
      : lookup(data.external.item_cache.result, "${var.cache_key}/token", "(N/A)")
    }"
    value = "${lookup(data.external.item_cache.result, var.cache_key, "") == ""
      ? join(",", data.aws_ami.item_ds.*.image_id)
      : lookup(data.external.item_cache.result, var.cache_key, "(N/A)")
    }"

    ## Other cached attributes of the data source

    other_name = "${lookup(data.external.item_cache.result, var.cache_key, "") == ""
      ? join(",", data.aws_ami.item_ds.*.name)
      : lookup(data.external.item_cache.result, "${var.cache_key}/other/name", "(N/A)")
    }"

    ## Any date values that are encoded as strings may get interpretted as date objects
    ## when parsed back out (i.e. during reading of the cache), so to force those to be
    ## loaded  *literally* with whatever value they had, we embed a prefix "STR:" in the
    ## value when saving down below, then here when we read from the cache, we strip it
    
    other_creation_date = "${lookup(data.external.item_cache.result, var.cache_key, "") == ""
      ? join(",", data.aws_ami.item_ds.*.creation_date)
      : replace(lookup(data.external.item_cache.result, "${var.cache_key}/other/creation_date", "(N/A)"), "/^STR:/", "")
    }"
  }
}

## Step #4:  for each cachable item, we need to define a null
## resource that has a provisioner that is used to update the
## cached value if it has been newly retrieved, for next time
## But the method that updates the cache needs to account for
## **parallel** execution, which is how TF creates/provisions
## resources, so if the cache is implemented using a method
## that is inherintly single-access, such as writing to a
## local file write, then we need to somehow account for that
## such as retries (in the example command script down below)
resource "null_resource" "item_cache_save" {
  triggers = {
    cache_value = "${data.null_data_source.item_value.outputs["value"]}"
    cache_token = "${data.null_data_source.item_value.outputs["token"]}"

    cache_other_name          = "${data.null_data_source.item_value.outputs["other_name"]}"
    cache_other_creation_date = "${data.null_data_source.item_value.outputs["other_creation_date"]}"
  }

  provisioner "local-exec" {

    ## If we want to be able to cache and output any other property (other than Image ID)
    ## of the origin aws_ami data source, we need to store those in the cache as well so
    ## that they are available without having to execute the origin data source, so for
    ## that, we have the optional -CacheOther parameter to the cache-setting CLI which
    ## takes a PWSH map (oh, and we need to properly quote and escape quotes to be able
    ## to pass this to PWSH via the process invocation) for example:
    ##    -CacheOther "@{ key1 = 'value1'; key2 = 'value2' }"

    ## Any date values that are encoded as strings may get interpretted as date objects
    ## when parsed back out (i.e. during reading of the cache), so to force those to be
    ## saved *literally* with whatever value they had, we embed a prefix "STR:" in the
    ## value, then up above where we read from the cache, we strip it back out

    command = "${path.module}/res/Set-TFCache.ps1 ${
      var.cache_root} ${
      var.cache_key} ${
      data.null_data_source.item_value.outputs["value"]} ${
      data.null_data_source.item_value.outputs["token"]} -CacheOther @{ name = \"${
      data.null_data_source.item_value.outputs["other_name"]}\"; creation_date = \"STR:${
      data.null_data_source.item_value.outputs["other_creation_date"]}\" }"

    interpreter = ["pwsh", "-Command"]
  }
}
