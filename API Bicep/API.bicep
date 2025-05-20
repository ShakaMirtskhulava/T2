// Required parameters
param appName string
param location string = resourceGroup().location

// App Service Plan parameters
param appServicePlanName string = '${appName}-plan'
param appServicePlanSku string = 'B1'
param appServicePlanTier string = 'Basic'
param createAppServicePlan bool = true
param existingAppServicePlanId string = ''

// Optional parameters with defaults
param containerImage string = 'mcr.microsoft.com/appsvc/staticsite:latest'
param containerRegistryUrl string = ''
param usePrivateContainerRegistry bool = false
param acrUseManagedIdentity bool = false

// Docker registry authentication
param usePrivateDockerRegistry bool = false
param dockerRegistryServerUrl string = ''
param dockerRegistryUsername string = ''
@secure()
param dockerRegistryPassword string = ''

// App Service configuration
param numberOfWorkers int = 1
param alwaysOn bool = false
param http20Enabled bool = false
param minTlsVersion string = '1.2'
param ftpsState string = 'FtpsOnly'
param minimumElasticInstanceCount int = 1
param use32BitWorkerProcess bool = true
param clientCertEnabled bool = false
param clientCertMode string = 'Required'

// Network settings
param httpsOnly bool = true
param vnetRouteAllEnabled bool = false
param vnetImagePullEnabled bool = false
param vnetContentShareEnabled bool = false
param publicNetworkAccess string = 'Enabled'
param ipSecurityRestrictionsDefaultAction string = 'Allow'

// CORS settings
param corsAllowedOrigins array = []
param corsSupportsCredentials bool = true

// Advanced options
param keyVaultReferenceIdentity string = 'SystemAssigned'
param autoHealEnabled bool = false
param customDomainVerificationId string = ''

// Compute the Linux FX version (for container apps)
var linuxFxVersion = usePrivateContainerRegistry 
  ? 'DOCKER|${containerRegistryUrl}/${containerImage}'
  : 'DOCKER|${containerImage}'

// Determine the App Service Plan ID to use
var appServicePlanResourceId = createAppServicePlan 
  ? appServicePlan.id 
  : existingAppServicePlanId

// Create App Service Plan if requested
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = if (createAppServicePlan) {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: appServicePlanTier
  }
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
}

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: appName
  location: location
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${appName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${appName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanResourceId
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: vnetRouteAllEnabled
    vnetImagePullEnabled: vnetImagePullEnabled
    vnetContentShareEnabled: vnetContentShareEnabled
    siteConfig: {
      numberOfWorkers: numberOfWorkers
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: acrUseManagedIdentity
      alwaysOn: alwaysOn
      http20Enabled: http20Enabled
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: minimumElasticInstanceCount
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: clientCertEnabled
    clientCertMode: clientCertMode
    hostNamesDisabled: false
    ipMode: 'IPv4'
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: !empty(customDomainVerificationId) ? customDomainVerificationId : null
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: httpsOnly
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: publicNetworkAccess
    storageAccountRequired: false
    keyVaultReferenceIdentity: keyVaultReferenceIdentity
  }
}

resource webAppFtpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
  parent: webApp
  name: 'ftp'
  properties: {
    allow: false
  }
}

resource webAppScmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
  parent: webApp
  name: 'scm'
  properties: {
    allow: false
  }
}

resource webAppConfig 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: numberOfWorkers
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: linuxFxVersion
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: acrUseManagedIdentity
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: ''
    scmType: 'None'
    use32BitWorkerProcess: use32BitWorkerProcess
    webSocketsEnabled: false
    alwaysOn: alwaysOn
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: autoHealEnabled
    vnetRouteAllEnabled: vnetRouteAllEnabled
    vnetPrivatePortsCount: 0
    publicNetworkAccess: publicNetworkAccess
    cors: !empty(corsAllowedOrigins) ? {
      allowedOrigins: corsAllowedOrigins
      supportCredentials: corsSupportsCredentials
    } : null
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    ipSecurityRestrictionsDefaultAction: ipSecurityRestrictionsDefaultAction
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsDefaultAction: ipSecurityRestrictionsDefaultAction
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: http20Enabled
    minTlsVersion: minTlsVersion
    scmMinTlsVersion: minTlsVersion
    ftpsState: ftpsState
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: minimumElasticInstanceCount
    azureStorageAccounts: {}
  }
}

// Add Docker registry credentials if using a private Docker registry
resource webAppDockerConfig 'Microsoft.Web/sites/config@2024-04-01' = if (usePrivateDockerRegistry) {
  parent: webApp
  name: 'appsettings'
  properties: {
    DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
    DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryUsername
    DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryPassword
  }
}

resource webAppHostNameBinding 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = {
  parent: webApp
  name: '${appName}.azurewebsites.net'
  properties: {
    siteName: appName
    hostNameType: 'Verified'
  }
}

// Output the web app URL and other useful properties
output webAppName string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
output webAppResourceId string = webApp.id
