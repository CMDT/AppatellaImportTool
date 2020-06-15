# Installation of Postgres, NodeJS runtime and Google Chrome browser on Windows 10
## Postgres
1. Go to the [Postgres Website download page](https://www.postgresql.org/download/windows/)
    1. Click on the link '[Download the installer](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)'. This will take you to the EDB website.
    1. Choose the download for your platform. For this article, we used [12.3 - Windows x86-64](http://www.enterprisedb.com/postgresql-tutorial-resources-training?cid=48).
    1. This will download an installation package to your computer.
    1. Once downloaded, allow it to run.
1. Windows Installer
The windows installer will run:
    1. Installation directory - choose the default option.
    1. Select Components:
        * PostgreSQL server
        * pgAdmin
        * Stack Builder
        * Command Line Tools
    1. Data Directory - choose the default option.
    1. Password for Postgres superuser (postgres)
        * Important! [Choose a good password](https://www.ncsc.gov.uk/blog-post/three-random-words-or-thinkrandom-0) 
    1. Port number
        * Should be the standard postgres port number of: 5432
    1. Locale
        * Choose the default locale
    1. The installer will install Postgres onto Windows 10.
    1. The installer will finish with the option to run 'Stack Builder'
        * unselect this option - it's not needed.
### NodeJS
NodeJS runs websites. The Appatella Import tool is actually a simple webpage and a small web  server, which you access with your browser.

1. Go to the [Node installer download page](https://nodejs.org/en/download/)
1. Click on LTS - Long Term Support; the most stable and supported versions.
1. Click on the [Windows Installer (.msi) 64-bit](https://nodejs.org/dist/v12.18.0/node-v12.18.0-x64.msi)
1. The installer will download and run:
    1. Accept the license terms
    1. Destination Folder: allow the default
    1. Custom Setup: Allow the default setup:
        * Node.js runtime
        * npm package manager
        * Online documentation shortcuts
        * Add to PATH
    1. Tools for native modules: all the default
        * YES: install the necessary tools 
1. Allow Node.js installer to install the necessary files.
1. Afterwards, a terminal window will pop-up,to install the 'Native Modules'. 
    1. Allow this to run (press any key to continue...)
    1. This application will attempy to connect to a website to download packages. You may get an error. If so, take a look at the note at the end of this article.

### Chrome Browser

To support our development on Android and iOS, all our work has been done using Safari and [Google Chrome](https://www.google.com/chrome/) Browsers.


### Database Tool
A database GUI is a nice, easy way of looking at what's in your database.
For Windows 10, we use DBeaver.

1. Go to the [DBeaver website](https://dbeaver.io/)
1. Choose 'download'
1. Choose 'Community Edition'
1. Download the 64-bit installer for the community edition
1. Start the installation:
    1. Select a language
    1. Accept the license agreement
    1. Allow ONLY me to use the application
    1. Accept user account control to install the application
    1. Accept the installation options:
        1. DBeaver community: essential
        1. Reset settings (not needed for your first installation)
        1. Associate .sql files: Useful
    1. Choose the install location: 
        1. Allow the default
    1. Choose the Start Menu folder
        1. Allow the default
1. The installation will continue
1. Finish, by creating a desktop shortcut
1. Run the application
    1. Windows Firewall may ask you to use Private networks.
    1. DBeaver will ask you if you want to install a sample database. You don't need to do this.
    1. DBeaver will ask you to connect to a database
        1. Select PostgreSQL
        1. Use connection view: 'advanced'
    1. DBeaver will ask to download 'driver' files for Postgres
        1. Allow all suggested downloads.
    1. DBeaver will attempt to connect to your default database. Use these defaults, and the password you supplied for your user, above.
        * localhost
        * user: 'postgres'
        * database: 'postgres
    
    
### Hardening
The Appatella Import Tool will populate your Postgres database with data exported from Appatella. 
This is data on individuals, for which you are responsible, under GDPR (or the data protection regulations for your nation)
There is excellent information to be found on the [ICO website](https://ico.org.uk/for-organisations/guide-to-data-protection/introduction-to-data-protection/some-basic-concepts/) 

You need to protect yourself and the individuals for whose data you are reponsible, by:

1. Ensuring access to the database is ONLY from the computer running the database.
1. Ensuring access to the database is ONLY from a person providing a username and password for the database (additional to the username and password for the computer)
1. Ensuring there can be no access to the data, via other means; encryption in-place.

##### 1. Limiting access to the running computer
By default, your database is set-up to allow only connections from the computer running the database. This is known as 'localhost'. 

##### 1. Limiting access to specific users
This tool enables access to your database by the default user (postgres). You will have set access to this user only at installation, by use of a strong password. 

##### Enabling encryption in-place
Windows 10 provides [encryption facilities](https://support.microsoft.com/en-us/help/4028713/windows-10-turn-on-device-encryption) to prevent access to data in the event of theft of your computer.
It's essential that you ensure these are enabled.
Some Windows 10 devices come with encryption turned on by default, and you can check this by going to Settings > System > About and scrolling down to “Device Encryption.” 

If your laptop doesn’t support Device Encryption, you can use Windows’ other built-in encryption tool: BitLocker. BitLocker is available only on Professional versions of Windows and above (a $99 upgrade for Home edition users), but it’s incredibly easy to set up. Just head to Windows’ Control Panel > System and Security > Manage BitLocker. Select your operating system drive and click the “Turn On BitLocker” button, following the prompts to create a password that will function as your encryption key. Be sure to store your BitLocker key in a safe place — somewhere not on that computer — in case something goes wrong.

If neither of those is an option, a free program called VeraCrypt can encrypt your entire hard drive, requiring your password when you boot your computer. It’s not quite as simple, straightforward and built-in as Windows’ Device Encryption and BitLocker, but if it’s your only option, it’s worth looking into.



---

NOTE: Errors downloading Additional Tools:

The 'NodeJS' additional tools are used because some package need to build and run native code. The Additional Tools enable this.

If you get an error like this, when downloading and installing the native tools:

```bash
    Exception calling "DownloadString" with "1" argument(s): "The request was aborted: Could not create SSL/TLS secure
channel."
At line:1 char:1
+ iex ((New-Object System.Net.WebClient).DownloadString('https://chocol ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : WebException

choco : The term 'choco' is not recognized as the name of a cmdlet, function, script file, or operable program. Check
the spelling of the name, or if a path was included, verify that the path is correct and try again.
At line:1 char:95
+ ... .DownloadString('https://chocolatey.org/install.ps1')); choco upgrade ...
+                                                             ~~~~~
    + CategoryInfo          : ObjectNotFound: (choco:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```

It is because your computer is set-up to talk to the download service using an older protocol than the one it supports.
To fix this, you will need to cancel the current process, issue a command, and startthe process again:

1. Cancel the process: You can type 'ENTER' as prompted by the script, or simply dismiss the window
2. Issue the command:
    1. In the search box, next to the 'Windows' button, type 'Power'
    2. Windows will give you a shortcut to 'Windows Power Shell'
    3. Right-click it, and choose the option 'Run As Administrator'
    4. Windows Power Shell will start
    5. Paste in the following command:
```
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord 
```
3. Explanation: the command will cause windows to try out a more advanced level of protocol for all connections it makes to servers on the internet. This is OK: most websites already use these protocols. If they don't, windows will simply drop back to connect using the orignial settings.
4. Restarting the process:
    1. In the search box, next to the 'Windows' button, type 'nodejs'
    2. Windows will give you a list of options. Choose 'Install Additional Tools For Node.js'
    3. The process will restart. 
