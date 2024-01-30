# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]

* System dependencies

docker

* Configuration

```
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
bundle config mirror.https://rubygems.org https://gems.ruby-china.com
gem install rails -v 7.0.2.3
pacman -S postgresql-libs
cd ~/repos
rails new --api --database=postgresql --skip-test mangosteen
code mangosteen
// open a new terminal
bundle exe rails server
```

* Database creation

```
docker run -d      --name db-for-mangosteen      -e POSTGRES_USER=mangosteen      -e POSTGRES_PASSWORD=123456      -e POSTGRES_DB=mangosteen_dev      -e PGDATA=/var/lib/postgresql/data/pgdata      -v mangosteen-data:/var/lib/postgresql/data      --network=network1      postgres:14
```

* Database initialization

bin/rails db:migrate RAILS_ENV=development

* How to run the test suite

rspec

tips: rember start db-for-mangosteen before run rspec

* Deployment instructions

bin/pack_for_remote.sh

* Development

bin/rails s

or

bundle exe rails s
