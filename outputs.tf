### djl-tf-server Private Hostname
output "djl-tf-server_ip" { value = aws_instance.djl-tf-server.private_ip}
#output "djl-tf-server_pw" { value = rsadecrypt(aws_instance.djl-tf-server.password_data,file("/Users/lwdvin/Documents/SSH_Keys/DemoVPC_Key_Pair.pem")) }


output "aws_iam_key" { value = aws_iam_access_key.iac_iam_user.id }
output "aws_iam_secret" {  value = nonsensitive(aws_iam_access_key.iac_iam_user.secret) }