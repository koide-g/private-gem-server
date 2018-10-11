#!/bin/sh

sudo yum -y update

cat /usr/share/zoneinfo/Asia/Tokyo > /etc/localtime
cat << EOL | sudo tee /etc/sysconfig/clock
ZONE="Asia/Tokyo"
UTC=true
EOL

sudo yum -y install git

# for ruby
echo 'Install ruby dependencies'
sudo yum -y install gcc gcc-c++
sudo yum -y install libffi-devel gdbm-devel
sudo yum -y install readline-devel openssl-devel zlib-devel

echo "Remove ruby 2.0.0"
yum remove -y ruby

echo "Clone rbenv and ruby-build"
rm -rf $HOME/.rbenv
git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build

echo 'export RBENV_ROOT="${HOME}/.rbenv"'                       >> $HOME/.bash_profile
echo 'export PATH="${RBENV_ROOT}/bin:$PATH"'                    >> $HOME/.bash_profile
echo 'export PATH="${RBENV_ROOT}/plugins/ruby-build/bin:$PATH"' >> $HOME/.bash_profile
echo 'eval "$(rbenv init -)"'                                   >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "Install ruby v2.5.1"
rbenv install 2.5.1

echo "Set default ruby version"
rbenv global 2.5.1
rbenv versions

echo "Install bundler"
rbenv exec gem install bundler
source $HOME/.bash_profile

echo "Move to app/ and bundle install"
mkdir $HOME/app
cd $HOME/app

cp /vagrant/Gemfile .
cp /vagrant/.ruby-version .
cp -R /vagrant/.bundle .
cp /vagrant/config.ru .
ls -al

bundle install --path=vendor/bundle
bundle exec rackup -o ${RACKUP_LISTEN_HOST:-localhost}
