### Install Nginx + fcgi

    sudo apt install nginx -y fcgiwrap

copy default file to /etc/nginx/sites-enabled/default

    sudo systemctl restart nginx

### files are available here:
`https://github.com/muhammednagy/peatio/tree/stable/eth`
### cgi files

copy the cgi files to /var/www/html/cgi-bin and update total.cgi with your username

    sudo chown www-data:www-data -R /var/www/html/cgi-bin
    sudo chmod +x /var/www/html/cgi-bin/*

### Install filter service
copy total.js to /var/www

    sudo chown www-data:www-data /var/www/total.js
don't forget to edit service.rb with your url

    sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs ruby-all-dev ruby
    sudo gem install web3 -v 0.1.0
    sudo gem install httparty
copy service.rb file to /home/ubuntu/

don't forget to update the username in filter.service
copy filter.service file to /etc/systemd/system/filter.service

    sudo systemctl start filter
    sudo systemctl enable filter


###Run Parity

#Steps to setup Parity:

1. `wget https://releases.parity.io/v2.2.1/x86_64-unknown-linux-gnu/parity`
2. `chmod +x parity`
3. `sudo mv parity /usr/loca/bin`
Sync parity :
4. `parity --jsonrpc-interface=0.0.0.0 --jsonrpc-apis eth,personal,net,web3,rpc --geth`
5.For testnet :
`parity --chain ropsten --jsonrpc-interface=0.0.0.0 --jsonrpc-apis eth,personal,net,web3,rpc --geth`
