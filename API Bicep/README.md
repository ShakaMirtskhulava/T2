# Azure App Service Bicep Template

This template allows you to deploy an Azure App Service (Web App) running a container in multiple environments. The template includes automatic App Service Plan creation and resource group management for a complete deployment experience.

## Structure

- `API.bicep` - The main Bicep template file with all resource definitions
- `Parameters/` - Directory containing environment-specific parameter files:
  - `parameters.prod.json` - Production environment settings
  - `parameters.presentation.json` - Presentation environment settings

## Prerequisites

- An Azure account with an active subscription
- Access to the Azure Portal
- Sufficient permissions to deploy resources in your Azure subscription

## Private Docker Registry Configuration

This template supports deploying container images from private Docker repositories. The template includes parameters for Docker registry authentication:

### Docker Registry Parameters

- `usePrivateDockerRegistry` - Set to `true` to enable private Docker registry authentication
- `dockerRegistryServerUrl` - The URL of your Docker registry (e.g., `https://index.docker.io` for Docker Hub)
- `dockerRegistryUsername` - Your Docker registry username
- `dockerRegistryPassword` - Your Docker registry password (secured)

### Common Docker Registry URLs

- Docker Hub: `https://index.docker.io`
- Azure Container Registry: `https://<registry-name>.azurecr.io`
- GitHub Container Registry: `https://ghcr.io`

## How to Use

### 1. Customize Parameter Files

Edit the parameter files in the `Parameters` folder to match your environment-specific settings:

- Set your Azure subscription ID 
- Customize container images for each environment
- Configure App Service Plan SKU and tier
- Configure environment-specific settings (CORS, TLS, etc.)

### 2. Deploy Using Azure Portal

Since Azure Portal requires ARM JSON templates rather than Bicep files directly, follow these steps:

#### Step 1: Convert Bicep to ARM JSON Template

1. Go to [Bicep Playground](https://aka.ms/bicepdemo)
2. Copy and paste the content of `API.bicep` into the left panel
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


## Parameter Reference

The template accepts the following parameters:

### Required Parameters
- `appName` - Name of the App Service
- `subscriptionId` - Your Azure subscription ID
- `location` - Azure region (defaults to resource group location)

### App Service Plan Parameters
- `createAppServicePlan` - Whether to create a new App Service Plan (true) or use existing (false)
- `appServicePlanName` - Name for the new App Service Plan
- `appServicePlanSku` - SKU for the App Service Plan (B1, S1, P1V2, etc.)
- `appServicePlanTier` - Tier for the App Service Plan (Basic, Standard, Premium, etc.)
- `existingAppServicePlanId` - Resource ID of existing App Service Plan (if not creating new)

### Container Settings
- `containerImage` - Docker image name/tag
- `containerRegistryUrl` - Private container registry URL (if used)
- `usePrivateContainerRegistry` - Whether to use private registry
- `acrUseManagedIdentity` - Whether to use managed identity for ACR

### Docker Registry Authentication
- `usePrivateDockerRegistry` - Whether to authenticate with a private Docker registry
- `dockerRegistryServerUrl` - Docker registry server URL (e.g., https://index.docker.io)
- `dockerRegistryUsername` - Username for Docker registry authentication
- `dockerRegistryPassword` - Password for Docker registry authentication (secure parameter)

### App Service Configuration
- `numberOfWorkers` - Number of worker processes
- `alwaysOn` - Keep the app always running
- `http20Enabled` - Enable HTTP/2
- `minTlsVersion` - Minimum TLS version
- `ftpsState` - FTPS configuration
- And many more...

### Network and Security Settings
- `httpsOnly` - Enforce HTTPS-only access
- `clientCertEnabled` - Require client certificates
- `clientCertMode` - Client certificate mode (Required, Optional, etc.)
- `corsAllowedOrigins` - Array of allowed CORS origins

See the template file for all available parameters and their defaults.
