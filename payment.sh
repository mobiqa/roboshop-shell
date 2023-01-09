source common.sh

component=catalogue
schema_load=false

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "Variable roboshop_rabbitmq_password is missing"
  exit
fi

PYTHON
