# Project Title: Madara-Karnot Automation

This project provides an automation script (`madara.sh`) designed to streamline the setup and deployment process for StarkNet contracts. It ensures the necessary environment is prepared, clones a specific repository, installs dependencies, and executes contract deployment. The script intelligently checks for the presence of `starkli` and installs it if necessary before proceeding with deployment.

## Getting Started

Follow these instructions to set up and automate the deployment process on your local machine.

### Prerequisites

Ensure the following tools are installed on your system:
- Git
- Node.js and npm
- curl and wget
- `at` and `cron` for task scheduling

### Installation and Running the Script

1. **Obtain the Script**

   Use `wget` to download `madara.sh` and make it executable:

   ```bash
   wget https://raw.githubusercontent.com/dante4rt/Ramanode-Guides/main/Madara-Karnot/madara.sh && chmod +x madara.sh
   ```

2. **Run the Script**

   Execute the script with:

   ```bash
   ./madara.sh
   ```

### Automating the Script with Crontab

To schedule the script to run automatically at specified intervals:

1. **Edit Crontab**

   Open your user's crontab file:

   ```bash
   crontab -e
   ```

2. **Schedule the Script**

   Add this line to run the script every 10 minutes:

   ```cron
   */10 * * * * /bin/bash /path/to/madara.sh >> /path/to/logfile.log 2>&1
   ```

   Be sure to replace `/path/to/madara.sh` with the full path where `madara.sh` is located and `/path/to/logfile.log` with your desired log file path.

3. **Save and Exit**

   After adding the line, save your changes and exit the editor. Your crontab will automatically save and apply the new job.

### Verifying Your Cron Job

Check your scheduled cron jobs to confirm the script has been added:

```bash
crontab -l
```

You should see the newly scheduled task for `madara.sh`.

## Additional Notes

- **Logging**: The script's output, including any errors, will be redirected to the specified log file. Adjust the log file path as needed to suit your preferences.
- **Cron Environment**: Remember, cron jobs run in a minimal environment. Set any required environment variables within the script or crontab file.
- **Security**: Always review scripts before downloading and executing them, especially when running commands as a superuser.