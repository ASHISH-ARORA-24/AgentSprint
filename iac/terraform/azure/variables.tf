variable "client_code" {
  description = "Client code for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resource groups."
  type        = string
  default     = "Central India"
}
