Vagrant.configure('2') do |config|
  config.vm.box      = 'ubuntu/xenial64'
  config.vm.hostname = 'nisda'

  config.vm.network 'private_network', ip: '192.168.20.10'

  config.vm.provider 'virtualbox' do |vb|
    vb.name   = 'nisda'
    vb.memory = 512
    vb.cpus   = 1
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.provision 'shell', inline: <<-SHELL
    apt-get update
    apt-get install -y ruby ruby-dev build-essential \
                       npm nodejs-legacy \
                       libjpeg-progs netpbm \
                       jq \
                       awscli

    echo "gem: --no-document --no-rdoc --no-ri" > /etc/gemrc
    gem install bundler

    npm install -g netlify-cli

    echo 'export NISDA_PHOTO_URI=https://example.com/photos/' >> /home/vagrant/.profile
    echo 'export CDN_URI=../pepper/'                          >> /home/vagrant/.profile
    echo 'cd /vagrant/'                                       >> /home/vagrant/.profile

    echo 'aws configure --profile nisda-s3'
  SHELL
end
