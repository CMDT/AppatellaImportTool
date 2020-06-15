# Installation of Postgres and NodeJS runtime on macos
## Postgres
1. Go to [Postgres.app](https://postgresapp.com/)
    1. Follow the instructions on this page.
    1. MAKE SURE that you set up the $PATH to use the command-line tools.
1. Now you should have a Postgres instance running on your Mac

### Graphical tools
We recommend you purchase and install [Postico](https://eggerapps.at/postico/), although DBeaver, will work just as well.

### Hardening
This tool will populate your Postgres datbase with data exported from Appatella. 
This is data on individuals, for which you are responsible, under GDPR (or the data protection regulations for your nation)
There is excellent information to be found on the [ICO website](https://ico.org.uk/for-organisations/guide-to-data-protection/introduction-to-data-protection/some-basic-concepts/) 

Your postgres database will protect you and the individuals for whose data you are reponsible, by:

1. Ensuring access to the database is ONLY from the computer running the database.
1. Ensuring access to the database is ONLY from a person providing a username and password for the database (additional to the username and password for the computer)
1. Ensuring there can be no access to the data, via other means; encryption in-place.

##### 1. Limiting access to the running computer
By default, your database is set-up to allow only connections from the computer running the database. This is known as 'localhost'. 

##### 1. Limiting access to specific users
This tool enables access to your database by the default user (postgres). You will have set access to this user only at installation, by use of a strong password. 

##### Enabling encryption in-place
All modern Macs (since about 2003) have a feature called FileVault that encrypts your entire system drive. Just open your Mac’s System Preferences, head to Security & Privacy and select the FileVault tab. Click the “Turn On FileVault” button to create a password and begin the encryption process. Store your key in a safe place (not on that computer) in case you ever get locked out.



    