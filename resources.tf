# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_objectstorage_bucket" "storage" {
  compartment_id = data.oci_identity_compartments.application.compartment[0].id
  for_each       = {
    for bucket in var.configuration.storage.buckets : bucket.name => bucket
    if  bucket.stage <= var.configuration.resident.stage
  }
  name           = each.value.name
  namespace      = data.oci_objectstorage_namespace.tenancy.namespace
  access_type    = each.value.access_type
  auto_tiering   = var.configuration.resident.stage > 1 ? "Enabled" : "Disabled"
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = local.module_freeform_tags
  kms_key_id     = var.configuration.resident.stage > 1 ? var.assets.encryption.keys[var.configuration.storage.bucket.key] : null
  metadata       = each.value.metadata
  object_events_enabled = each.value.object_events_enabled
  storage_tier   = each.value.storage_tier
  versioning     = alltrue(each.value.objects == "Documents", var.assets.resident.stage > 1 ) ? "ENABLED" : "DISABLED"
}