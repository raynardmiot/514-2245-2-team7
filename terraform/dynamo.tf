resource "aws_dynamodb_table" "labels_table" {
    name           = "CatImageLabels"
    billing_mode   = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 20
    hash_key       = "Key"

    attribute {
      name = "Key"
      type = "S"
    }
}