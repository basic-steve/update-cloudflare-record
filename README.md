# Update cloudflare record
This is a simple and ugly script to update a single __cloudflare A record__ and get notified when it happens via email
Use case: home server, raspberry pi open on network...

## Suppported OS
- Linux
- macOS

## Usage
```
./script.sh [-s config_file.json]
```

## Installing
Just clone it on your machine
  ```
  git clone https://github.com/CatMonster/update-cloudflare-record.git
  ```

## Configuring
Now you need to retrive all needed data to make work properly the script
#### Cloudflare
Api Key
1) Log into your cloudflare account -> [Cloudflare dashboard](https://dash.cloudflare.com/)
2) Go on to your profile page
3) At the page end there is a section called "API Keys", hit "View" button to get the __Global API Key__

#### Record
1) Select choosen zone
2) Go under "DNS" section
3) Below all your DNS records hit "API"
4) Copy "List DNS Records"
5) By using [postman](https://www.getpostman.com/apps) or whatever method you prefer, use that API call to get a full list of all records inside the specific zone

Now you can fill out the [config.json](https://github.com/CatMonster/update-cloudflare-record/blob/master/config.json), under cloudflare object you need to put all retrived data until now like in this exaple below
```
...

"cloudflare" : {
    "email": "your_cloudflare_account_email",
    "zones": "zone_id",
    "api_key": "your_api_key",
    "record": "id"
  },

...
```
#### Mailing system
If __ssmtp__ isn't configured yet, you need to find the working config for your mail provider, Google and stackExchange are best your friends :smirk:, I'm using gmail and [this config](https://unix.stackexchange.com/a/381197/325117) works fine for me.

In config.json you need to put the receiver and the preferred subject you want.
Any modification at the mail body can be done on [mail_template](https://github.com/CatMonster/update-cloudflare-record/blob/master/mail_template) file.
#### Running periodically
Personally for home use I sat a cron running every minute, it's pretty safe because Cloudflare api can be called 1200 times in 5 minutes, for [ipfy.org](https://www.ipify.org/) you can do "millions of requests per minute" as they say; keep that in mind if you are planning to conquest the galaxy.

To set a cron, type ```crontab -e``` and you'll get a file like that
![Image of](https://i.imgur.com/UPHlZrog.png)

Make sure to set system variables to get all commands working as well
```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
```
and call your script 

```
* * * * * cd /home/user/scripts/update-cloudflare-record/; ./script.sh -s config.json
```

As mentioned above i run that every minute; by replacing __* * * * *__ you can set whatever time you want. If you are cron noob like me take a look at [crontab guru's website](https://crontab.guru/) and all their [examples](https://crontab.guru/examples.html)

## Info and Docs
Cloudflare api doc --> https://api.cloudflare.com/

# Hope you found this script useful :wave: