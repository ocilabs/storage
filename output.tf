# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "bucket_ids" {
  description = "The block volume group details"
  value = {
    for bucket in oci_objectstorage_bucket.storage :
    bucket.display_name => bucket.id
  }
}
