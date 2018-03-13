
## The only output value we export is the AMI image ID from the inner
## aws_ami resource.  If we need any other exported attributes, such
## as the AMI name or any of its characteristics, we can just add them
## here as needed, HOWEVER, we also need to add them to the cached
## cached values since they won't be resolvable from just the cached
## data otherwise.

output "_is_cached" {
  value = "${data.null_data_source.item_value.outputs["_is_cached"]}"
}

output "image_id" {
  value = "${data.null_data_source.item_value.outputs["value"]}"
}

output "name" {
  value = "${data.null_data_source.item_value.outputs["other_name"]}"
}

output "creation_date" {
  value = "${data.null_data_source.item_value.outputs["other_creation_date"]}"
}
