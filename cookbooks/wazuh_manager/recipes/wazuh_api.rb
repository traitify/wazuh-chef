

<<<<<<< HEAD
case node['platform']
when 'debian', 'ubuntu'

=======
if platform_family?('ubuntu', 'debian')
>>>>>>> 1d30141... Updated recipes to "if platform_family" conditional. Added raise exception
  bash 'Install nodejs' do
    code <<-EOH
      cd /tmp &&
      curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
      EOH
    not_if { ::File.exist?('/etc/apt/sources.list.d/nodesource.list') }
  end

<<<<<<< HEAD
when 'redhat', 'centos', 'fedora'
=======
  apt_package 'wazuh-api' do
    version "#{node['wazuh-manager']['version']}-1"
  end

elsif platform_family?('redhat', 'centos', 'rhel', 'amazon')
>>>>>>> 1d30141... Updated recipes to "if platform_family" conditional. Added raise exception

  bash 'Install nodejs' do
    code <<-EOH
      cd /tmp &&
      curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
      EOH
    not_if { ::File.exist?('/etc/yum.repos.d/nodesource-el.repo') }
  end

<<<<<<< HEAD
=======
  yum_package 'wazuh-api' do
    version "#{node['wazuh-manager']['version']}-1"
  end
else
  raise "Currently platforn not supported yet. Feel free to open an issue on https://www.github.com/wazuh/wazuh-chef if you consider that support for a specific OS should be added"
>>>>>>> 1d30141... Updated recipes to "if platform_family" conditional. Added raise exception
end

package ['nodejs', 'wazuh-api']

begin
  api_keys = Chef::EncryptedDataBagItem.load('wazuh_secrets', 'api')
  log "Api credentials found. Loading them..." do
    message "-----API KEYS FOUND-----"
    level :info
  end
rescue ArgumentError, Net::HTTPServerException
  api_keys = {'htpasswd_user' => "#{node['api']['user']}", 'htpasswd_passcode' => "#{node['api']['passcode']}"}
  log "No api crendentials. Installation will continue with defaults (foo:bar)..." do
    message "-----NO API KEYS-----"
    level :info
  end
end

if (node['api']['password_plaintext'] == "yes")
  bash "Installing user..." do
    code <<-EOH
    cd /var/ossec/api/configuration/auth/
    node htpasswd -c user #{api_keys['htpasswd_user']} -b #{api_keys['htpasswd_passcode']}
    cd
    EOH
  end

else 
  file "#{node['ossec']['dir']}/api/configuration/auth/user" do
    mode '0650'
    owner 'root'
    group 'root'
    content "#{api_keys['htpasswd_user']}:#{api_keys['htpasswd_passcode']}"
    action :create
  end
end

service 'wazuh-api' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :restart]
end