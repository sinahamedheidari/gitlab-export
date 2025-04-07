# Gitlab Export
Shell script to create and download project exports from GitLab using the GitLab API.

When exporting a group in GitLab via the UI, it only exports the project structure—not the actual projects. To back up all projects within a group, you need to export each project individually. The Bash script `export_gitlab_projects.sh` helps automate this by generating and downloading project exports easily.

### Prerequisites
Before running the script, set the following variables:

| Variable | Description|
| --- | --- |
|GROUP_ID | The ID of the group whose projects you want to export |
|PRIVATE_TOKEN | GitLab private token with read/write API access |
|GITLAB_ADDRESS | Your GitLab instance URL |
|BACKUP_PATH | Directory path where downloaded files will be saved |
|PROJECT_LIST_LENGTH | Set to 0 to read all projects in the group |
|RECORD_PER_PAGE | Number of records to retrieve per page |

### How to use
```
git clone https://github.com/sinahamedheidari/gitlab-export
chmod +x export_gitlab_projects.sh
## Run the script
./export_gitlab_projects.sh
```
**NOTE**: If you're downloading many projects, it's recommended to run the script inside a terminal multiplexer like screen, tmux, or similar tools to avoid interruptions.

### IMPORTANT NOTE
You might encounter the error 429 Too Many Requests while running the script. This is due to GitLab’s default API rate limits.

To bypass this:

   1. Go to: https://yourgitlab.com/admin/application_settings/network
   2. Under the "Import and export rate limits" section, set higher values or 0 (to disable limits temporarily).
   3. After the export is complete, revert these settings for security best practices.
