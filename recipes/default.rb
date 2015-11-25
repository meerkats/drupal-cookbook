#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: drupal
# Recipe:: default
#
# Copyright 2010, Promet Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
2
# install apache webserver

include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_expires"

# install php

include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_gd"

# install mysql database

include_recipe "mysql::server"

include_recipe "drupal::drush"

# setup database and user with required previleges

execute "mysql-install-drupal-privileges" do
  command "/usr/bin/mysql -h #{node[:drupal][:db][:host]} -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/drupal-grants.sql"
  action :nothing
end

template "/etc/mysql/drupal-grants.sql" do
  path "/etc/mysql/drupal-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user => node[:drupal][:db][:user],
    :password => node[:drupal][:db][:password],
    :database => node[:drupal][:db][:database],
    :host => node[:drupal][:db][:host]
  )
  notifies :run, "execute[mysql-install-drupal-privileges]", :immediately
end

execute "create #{node[:drupal][:db][:database]} database" do
  command "/usr/bin/mysqladmin -h #{node[:drupal][:db][:host]} -u root -p#{node[:mysql][:server_root_password]} create #{node[:drupal][:db][:database]}"
  not_if "mysql -h #{node[:drupal][:db][:host]} -u root -p#{node[:mysql][:server_root_password]} --silent --skip-column-names --execute=\"show databases like '#{node[:drupal][:db][:database]}'\" | grep #{node[:drupal][:db][:database]}"
end

template "#{node['drupal']['dir']}/sites/default/settings.php" do
  source "d7.settings.php.erb"
  mode "0644"
  variables(
    'database'        => node['drupal']['db']['database'],
    'user'            => node['drupal']['db']['user'],
    'password'        => node['drupal']['db']['password'],
    'host'            => node['drupal']['db']['host']
  )
end

# setup apache configuration

template "#{node[:apache][:dir]}/sites-available/#{node[:webapp][:domain]}.conf" do
  source "drupal.conf.erb"
  mode 0777
  group node[:apache][:user]
  group node[:apache][:group]
end

apache_site "#{node[:webapp][:domain]}.conf"

include_recipe "drupal::cron"
