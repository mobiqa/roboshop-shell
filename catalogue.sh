source common.sh

  print_head "Configuring NodeJS Repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  status_check

  print_head "Install NodeJS"
  yum install nodejs -y &>>${LOG}
  status_check

print_head "Add Application User"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${LOG}
  fi
  status_check

  mkdir -p /app &>>${LOG}

  print_head "Downloading App content"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
  status_check

  print_head "Cleanup Old Content"
  rm -rf /app/* &>>${LOG}
  status_check

  print_head "Extracting App Content"
  cd /app
  unzip /tmp/catalogue.zip &>>${LOG}
  status_check

  print_head "Installing NodeJS Dependencies"
    cd /app &>>${LOG}
    npm install &>>${LOG}
    status_check

  print_head "Configuring catalogue Service File"
  cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
  status_check

  print_head "Reload SystemD"
  systemctl daemon-reload &>>${LOG}
  status_check

  print_head "Enable catalogue Service "
  systemctl enable catalogue &>>${LOG}
  status_check

  print_head "Start catalogue service "
  systemctl start catalogue &>>${LOG}
  status_check

print_head "Copy MongoDB Repo file"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

print_head "Install MongoDB"
yum install mongodb-org -y  &>>${LOG}
status_check

print_head "Update MongoDB Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
status_check


print_head "Install MongoDB"
systemctl enable mongod &>>${LOG}
status_check

print_head "start  MongoDB"
systemctl restart mongod &>>${LOG}
status_check

print_head "Load Schema"
      mongo --host mongodb-dev.mobiqa.online </app/schema/catalogue.js &>>${LOG}
      status_check