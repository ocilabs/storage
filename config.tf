# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- //
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
// --- terraform provider --- //

// --- Administrator settings for storage resources --- //
data "oci_identity_compartments" "resident" {
  compartment_id = var.configuration.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = var.configuration.resident.name
  state          = "ACTIVE"
}

data "oci_objectstorage_namespace" "resident" {
  depends_on = [
    data.oci_identity_compartments.resident
  ]
  compartment_id = data.oci_identity_compartments.resident.compartment[0].id
}
data "oci_identity_compartments" "application" {
  compartment_id = var.configuration.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = try(var.configuration.application.compartment, var.configuration.resident.name)
  state          = "ACTIVE"
}
// --- Administrator settings for storage resources --- //


locals {
  module_freeform_tags = {
    # list of freeform tags, added to stack provided freeform tags
    terraformed = "Please do not edit manually"
  }
  merged_freeform_tags = merge(local.module_freeform_tags, var.assets.resident.freeform_tags)
  access_type = {
    "PRIVATE"  = "NoPublicAccess",
    "PUBLIC"   = "ObjectRead",
    "DOWNLOAD" = "ObjectReadWithoutList"
  }
}
// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}