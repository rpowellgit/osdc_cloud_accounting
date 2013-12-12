#!/usr/bin/env python
from salesforceocc import SalesForceOCC
import ConfigParser
import pwd
import pprint
import sys
import re
import subprocess

if __name__ == "__main__":
    sfocc = SalesForceOCC()
    #read in settings
    Config = ConfigParser.ConfigParser()
    Config.read("/etc/osdc_cloud_accounting/settings.py")
    sections = ['general','salesforceocc','tukey']
    settings = {}
    for section in sections:
        options = Config.options(section)
        settings[section]={}
        for option in options:
            try:
                settings[section][option] = Config.get(section, option)
            except:
                sys.stderr.write("exception on [%s] %s!" % section, option)

    #Load up a list of the users in SF that are approved for this cloud
    sfocc.login(username=settings['salesforceocc']['sfusername'], password=settings['salesforceocc']['sfpassword'])
    contacts = sfocc.get_contacts_from_campaign(campaign_name=settings['general']['cloud'],  statuses=["Approved User", "Application Pending"])
    members_list = sfocc.get_approved_users(campaign_name=settings['general']['cloud'], contacts=contacts)

    #Loop through list of members and run the bash scripts that will create the account
    #FIXME: Most of this stuff could be moved into the python, just simpler not to
    for username,fields in members_list.items():
        try:
            user_exists = pwd.getpwnam(username)
        except:
            if username:
                pprint.pprint(fields)
                if fields['Authentication_Method'] == 'OpenID':
                    method = 'openid'
                else:
                    method = 'shibboleth'
                
                #OpenIDs were the sart but now we need to check if anything
                #is set for this email field, Email is now just contact field
                if fields['login_identifier'] == 'None' or fields['login_identifier'] == None:
                    login_identifier = fields['Email']
                else:
                    login_identifier = fields['login_identifier']

                
                #I am bad at the None checking and convert it to a string at one point
                #convert none to default
                if fields['core_quota'] == 'None' or fields['core_quota'] == None:
                    fields['core_quota'] = settings['general']['core_quota']
                if fields['storage_quota'] == 'None' or fields['storage_quota'] == None:
                    fields['storage_quota'] = settings['general']['storage_quota']

                #Assemble command
                print "Creating new user:  %s" % username
                cmd = [
                    '/usr/local/sbin/create-user.sh',
                    fields['Name'],
                    fields['username'],
                    login_identifier,
                    method,
                    settings['tukey']['cloud'],
                    fields['core_quota'],
                    fields['storage_quota'] + 'TB',
                ]
                try:
                    print cmd
                    #result = subprocess.check_call( cmd )
                except subprocess.CalledProcessError, e:
                    sys.stderr.write("Error creating  new user:  %s\n" % username )
                    sys.stderr.write("%s\n" % e.output)
                

