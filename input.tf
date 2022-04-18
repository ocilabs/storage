# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "options" {
  description = "Input from the schema file."
  type = object({
    class    = string,
    password = string
  })
}

variable "configuration" {
  description = "Retrieve asset configurations."
  type = object({
    tenancy  = any,
    resident = any
  })
}

variable "assets" {
  description = "Retrieve deployment results."
  type = object({
    database   = any,
    encryption = any,
    network    = any,
    resident   = any
  })
}