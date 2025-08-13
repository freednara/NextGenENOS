# Community Activation Guide

Follow these steps to activate the Community site and make it available to external users.

1. **Deploy the metadata**

   ```bash
   sf project deploy start --source-path force-app/main/default/experiences
   ```

2. **Assign permissions**
   Assign the community permission set to external users:

   ```bash
   sf org assign permset --name Community_User --target-org <username>
   ```

3. **Publish the community**

   ```bash
   sf community publish --name Community --target-org <username>
   ```

4. **Activate the site**
   Ensure the community is activated from the Experience Cloud admin console or via the command line:
   ```bash
   sf community activate --name Community --target-org <username>
   ```

Replace `<username>` with the authenticated org username used for development.
