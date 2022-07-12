variable "lb_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range reserved for HTTP(S) Load Balancers."
}

variable "proxy_only_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range reserved for Regional Managed Proxies."
}
