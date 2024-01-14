/*
variable "cg_acces_key" {
  type = string
  default = "AKIA3Y2AWHAVBZFU64SH"

}

variable "cg_secret_key" {
  type = string
  default = "aiU/J+E+q2FEiE8j7cG9Zcz9mDg185FXioJYjxmv"

}
*/

variable "cg_account" {
  type = string
  default = ${{ secrets.ACCOUNTID }}
}

variable "cg_region" {
  type = string
  default = "us-east-1"
}

variable "cg_subnet_ids" {
  type = string
  default = ""
}
