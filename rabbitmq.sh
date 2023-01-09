source common.sh


if [ -z "${root_mysql_password}" ]; then
  echo "Variable root_mysql_password is missing"
  exit
fi


print_head "Configuring Erlang yum repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "Configuring Rabbitmq yum repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "Install Rabbitmq and Erlang"
yum install erlang rabbitmq-server -y &>>${LOG}
status_check

print_head "Enable Rabbitmq"
systemctl enable rabbitmq-server &>>${LOG}
status_check

print_head "Start Rabbitmq"
systemctl start rabbitmq-server &>>${LOG}
status_check

print_head "Add Application user"
rabbitmqctl list_users | grep roboshop &>>${LOG}
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>${LOG}
  fi
status_check

print_head "Add tags to Application user"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG}
status_check

print_head "Install Rabbitmq"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
status_check