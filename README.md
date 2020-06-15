# Appatella Import Tool

Based on AppatellaResearchAPI V 0.0.42. 

**Please note: the Appatella Export facility produces a single data file which is encrypted. The data within is pertinent to individuals. It is conformant to GDPR consent and revocation. You must be aware of your legal obligations in handling this data. If in doubt DO NOT extract.**

This tool is provided to help you import indiviual data from Appatella into a local Postgres database. 
During the import process, encrypted data is extracted, and will be stored on your computer momentarily before being destroyed.

For this reason, it's vital that your computer has an encrypted filesystem. More information is below.

## Installation

This tool will install a server on to your computer, which will create and update a Postgres database. To do this, you will need the following:

* A NodeJS runtime
* A Postgres database installation

To install on Windows 10, please see instructions [here](./win10install.md)
To install on macos, please see instructions [here](./macosinstall.md)

Once these basics have been installed:

1. Create a convenient folder on your filesystem
1. [Download this repository as a .zip](https://github.com/CMDT/AppatellaImportTool/archive/master.zip)
1. Open a command window at the base of this folder. Hint: you should be able to see this README.md file in it.
1. Type the following command:
    ```bash
    npm start
    ```
1. The Node Package Manager will run, and install the application, and all its dependencies.
1. Node will then start, and attempt to start the service. You will probablybe prompted for permission to do this.
1. The command window will finish running the server, with 
    ```
    SERVER: listening on 
    ```
    Indicating that it is waiting for a browser to connect.
1. Start your web-browser, and paste the following into the address bar:
```bash
http://localhost:8004/docs/
```
1. You should now see the Appatella Import Tool page.

## Creating an Export from Appatella

1. Using the Appatella Exercise Builder, you will have deployed Interventions to participants. You will have
    1. requested and obtained 'Constructor' capabilities
    1. requested and obtained 'Researcher' capabilities
    1. joined an Appatella organisation having Exercise Plans available for deployment
    1. obtained 'administrator' capabilities in the organisation.
    1. created Interventions
    1. deployed Exercise Plans to Interventions
    1. deployed Interventions to particpants
    1. ensured that participants have downloaded their Intervention to their mobile device, using the Appatella Player app.
    1. ensured that participants have shared their data with Appatella, using the Appatella Player app.
    1. ensured that particiants have performed some exercises, so there is data available for export.
1. In the Appatella Exercise Builder, you can search for exportable Interventions.
    1. In the Interventions list, type in a search term. You can use a number of combinations to get the Interventions you need, seperated by commas:
        * The IDs of interventions
        * The IDs of any components used by any interventions (Exercise Plans, Sessions, Exercises, Surveys, Sections, Questions)
        * The IDs (name) of any organisations, to which you have access
        * A date range (defined in [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html))
        * the keyword 'exportable'. This will filter on Interventions with the proper consent.
    1. Once you have the list of interventions you need, use the multiselect button to select the items to go into an export.
    1. Press the 'Export...' button
    1. In the 'Export'  dialog, specify the password required to protect the exported file.
    1. Download the export.

## Importing to your 'local' DB

1. You will need:
    1. your local database username and password
    1. the path to the downloaded Appatella export file
    1. the password for the export file.
2. In the Appatella Import Tool page, press 'POST' /import/
3. Fill in the following fields:
    1. source_path: the full path to your downloaded, encrypted file.
    1. secret: the password you attached to the exported file.
    1. destination_db: the name of the database to create.
    1. username: the username you created Postgres with.
    1. password: the password you create your Postgres username with.
4. Press 'Try it out!'
5. If everything went OK, the 'Response Code' should be 200. If not, the Response Body will contain some error information.
6. You can now start your Database GUI, and connect to the database.


## Finally
Your export is made available to you by the consent of of the person to whom it belongs. 
General Data Protection Regulations in the UK mandate that this consent can be revoked at any time.
This means you must be prepared to delete this export - and any other associated files which may identify an individual - on request.
Your export is tracked by Appatella. Please check back regularly for revokation requests.
When you have finished your analysis, you may keep any aggregated data which does not identify individuals.
You must delete the export, and remove the export record from your Appatella user account, to avoid confusion or unnecessary auditing.





