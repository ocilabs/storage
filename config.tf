# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.default_compartment_id
}

data "oci_core_volume_backup_policies" "volume_backup_policies" {
}

locals {
  vols_default = {
    compartment_id     = ""
    name               = "my-oci-block-volume"
    ad                 = 0
    size_in_gbs        = 60
    backup_policy_name = "Bronze"
    defined_tags       = {}
    freeform_tags      = {}
    source_id          = null
    source_type        = "volume"
    kms_key_id         = null
  }


  vols = var.vols != null ? var.vols : {}


  vols_w_o_kms = { for k, v in local.vols :
    k => v
    if v.kms_key_id == null
  }

  vols_w_kms = { for k, v in local.vols :
    k => v
    if v.kms_key_id != null
  }

  keys_vols_w_o_kms = keys(local.vols_w_o_kms)
  keys_vols_w_kms   = keys(local.vols_w_kms)
  total_vol_key_len = (length(local.keys_vols_w_o_kms) + length(local.keys_vols_w_kms))

  /*
  Logic explained:
  Use case:- Have volume group names input variable inside the volume interface. 
  1. First create a map of volume names to their ocids. refer all_vol_id_map below
  2. Then create a map named vol_ids of {volume group names : ocids}. the ocids are looked up from all_vol_id_map created in step 1.
  3. Finally in oci_core_volume_group resource we concat ext_vol_ids (which are user inputted external volumes) and vol_ids 
  */
  vol_grps_default = {
    volume_group_name = "my-oci-volume-group"
    ad                = 0
    compartment_id    = ""
    defined_tags      = {}
    freeform_tags     = {}
    all_vol_id_map = local.total_vol_key_len == null ? {} : merge(
      {
        for k in oci_core_volume.this_w_kms :
        k.display_name => k.id
      },
      {
        for k in oci_core_volume.this_w_o_kms :
        k.display_name => k.id
      }
    )
  }

  vol_ids = local.total_vol_key_len == null ? {} : {
    for k, v in local.vols :
    v.vol_grp_name => local.vol_grps_default.all_vol_id_map[k]...
    if v.vol_grp_name != null
  }
}

// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}