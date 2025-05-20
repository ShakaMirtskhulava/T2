# Azure SQL Database Bicep Template

This template allows you to deploy an Azure SQL Server and Database with full parameterization across multiple environments. The template is designed for flexible deployment to different environments (development, test, production, etc.) with appropriate configurations for each.

## Structure

- `sql-database.bicep` - The main Bicep template file with SQL Server and Database definitions
- `Parameters/` - Directory containing environment-specific parameter files:
  - `parameters.dev.json` - Development environment settings
  - `parameters.test.json` - Test environment settings
  - `parameters.prod.json` - Production environment settings
  - `parameters.presentation.json` - Presentation environment settings

## Prerequisites

- An Azure account with an active subscription
- Access to the Azure Portal
- Sufficient permissions to deploy resources in your Azure subscription

## How to Use

### 1. Customize Parameter Files

Edit the parameter files in the `Parameters` folder to match your environment-specific settings:

- Set your SQL Server name and credentials
- Configure database tier and capacity
- Set security configurations
- Define allowed IP addresses

### 2. Deploy Using Azure Portal

Since Azure Portal requires ARM JSON templates rather than Bicep files directly, follow these steps:

#### Step 1: Convert Bicep to ARM JSON Template

1. Go to [Bicep Playground](https://aka.ms/bicepdemo)
2. Copy and paste the content of `sql-database.bicep` into the left panel
3. The ARM JSON template will be automatically generated in the right panel
4. Copy the generated JSON to use in the portal

#### Step 2: Deploy Using Azure Portal

1. **Log in to the Azure Portal** (https://portal.azure.com)

2. **Navigate to your target resource group** (or create a new one)
   - Go to "Resource Groups" in the left menu
   - Select an existing resource group or click "Create" to make a new one

3. **Start the custom deployment**
   - In your resource group, click "+ Create" or "Add" 
   - Search for "Template deployment" or "Deploy a custom template"
   - Select "Template deployment (deploy using custom templates)"

4. **Upload your template**
   - On the "Custom deployment" page, click "Build your own template in the editor"
   - Paste the ARM JSON template you generated from the Bicep Playground
   - Click "Save"

5. **Provide parameters**
   - On the next screen, you can either:
     - Fill in parameters manually, or
     - Click "Load file" in the parameters section to upload your `parameters.<environment>.json` file

6. **Review and create**
   - Select your target subscription
   - Select or create your resource group
   - Review the settings
   - Click "Review + Create" and then "Create"

#### Step 3: Monitor Deployment

- You can monitor the deployment progress in the Azure Portal
- Once complete, you can navigate to the deployed SQL Server and Database

## Security Recommendations

### Password Management

The parameter files are set up to use KeyVault references for the SQL Server administrator password in dev, test, and prod environments:

```json
"administratorLoginPassword": {
  "reference": {
    "keyVault": {
      "id": "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/KeyVault-RG/providers/Microsoft.KeyVault/vaults/YourKeyVault"
    },
    "secretName": "sqlServerAdminPassword"
  }
}
```

For the presentation environment, a direct value is used for simplicity, but this should be replaced with a secure approach for any real deployment.

### Firewall Rules

- For development and test environments, the parameter files include sample IP rules
- For production, you should carefully configure IP restrictions to limit access
- Use `allowAzureServices: true` only if you need Azure services to access your database

## Parameter Reference

### Basic Parameters
- `sqlServerName` - Name of the SQL Server
- `location` - Azure region for deployment
- `databaseName` - Name of the database

### Authentication Parameters
- `administratorLogin` - SQL Server admin username
- `administratorLoginPassword` - SQL Server admin password (secure)

### Database Configuration
- `databaseEdition` - Database edition (Basic, Standard, Premium, etc.)
- `databaseTier` - Database tier (Basic, Standard, Premium, etc.)
- `databaseCapacity` - Database capacity (DTUs)
- `maxSizeBytes` - Maximum database size in bytes
- `zoneRedundant` - Whether the database is zone-redundant

### Security Parameters
- `enableAuditing` - Enable SQL auditing
- `enableAdvancedThreatProtection` - Enable Advanced Threat Protection
- `enableTransparentDataEncryption` - Enable Transparent Data Encryption
- `allowAzureServices` - Allow Azure services to access the SQL Server
- `ipAddressRules` - Array of IP address rules for the firewall

## Environment-Specific Configurations

Each environment has tailored settings appropriate for its use:

### Development
- Basic tier with minimal resources
- Minimal security features
- Local development access

### Test
- Standard tier with moderate resources
- Some security features enabled
- Test environment access

### Production
- Standard tier with substantial resources
- All security features enabled
- Zone redundancy for high availability
- Strict access controls

### Presentation
- Basic tier with minimal resources
- Simplified configuration for demos
- Demo environment access

## Outputs

The template provides the following outputs:
- SQL Server FQDN
- Database name
- SQL Server name
- Connection string
