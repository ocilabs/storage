# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "options" {
  description = "Input from the schema file."
  type = object({
    kms_key_id            = string,
    object_events_enabled = bool
  })
}

variable "configuration" {
  description = "Retrieve asset configurations."
  type = object({
    tenancy  = any,
    resident = any,
    storage  = any
  })
}

variable "assets" {
  description = "Retrieve deployment results."
  type = object({
    encryption = any,
    network    = any,
    resident   = any
  })
}