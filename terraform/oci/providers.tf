terraform {
    required_version = "~> 1.13.0"
    required_providers {
        oci = {
            source = "oracle/oci"
            version = "7.18.0"
        }
    }
}
