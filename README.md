# Appatella Import Tool

Based on AppatellaResearchAPI V 0.0.42. 

This tool is for import and export of course data into a local Postgres database, for offline analysis. 

**Please note: the Appatella Export facility produces a single data file which is encrypted. The data within is pertinent to individuals. It is conformant to GDPR consent and revocation. You must be aware of your legal obligations in handling this data. If in doubt DO NOT extract.**

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
http://localhost:8000/docs/
```
1. You should now see the Appatella Import Tool page.

## Creating an Export

1. Using the Appatella Exercise Builder, you will have deployed Interventions to participants. You will have
    1. requested and obtained 'Constructor' capabilities
    1. requested and obtained 'Researcher' capabilities
    1. joined an Appatella organisation having Exercise Plans available for deployment
    1. obtained 'administrator' capabilities in the organisation.
    1. created Interventions
    1. deployed Exercise Plans to Interventions
    1. deployed Interventions to particpants
    1. ensured that participants have downloaded their Intervention to their mobile device, using the Appatella Player app.
    1. ensured that participants have shared their data with Appatela, using the Appatella Player app.
    1. ensured that particiants have performed some exercises, so there is data available for export.
1. In the Appatella Exercise Builder, you can searcch for exportable Interventions.
    1. In the Interventions list, type in a search term. You can use a number of combinations to get the Interventions you need,seperated by commas
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

1. In the Appatella Import Tool page, press 'POST' import
2. 





