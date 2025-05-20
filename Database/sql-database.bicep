// Required parameters
param sqlServerName string
param location string = resourceGroup().location
param databaseName string = 'DMSDataBase'

// SQL Server admin credentials
@description('The administrator username of the SQL Server.')
param administratorLogin string

@description('The administrator password of the SQL Server.')
@secure()
param administratorLoginPassword string

// Database configuration
param databaseEdition string = 'Basic'
param databaseTier string = 'Basic'
param databaseCapacity int = 5
param maxSizeBytes int = 1073741824 // 1GB

// Optional configuration
param zoneRedundant bool = false
param enableAuditing bool = false
param enableAdvancedThreatProtection bool = false
param enableTransparentDataEncryption bool = true

// Allowed IP addresses for firewall rules
param allowAzureServices bool = true
param ipAddressRules array = []

// Resource definitions
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  kind: 'v12.0'
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

// Allow Azure services if enabled
resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = if (allowAzureServices) {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Add IP address rules if provided
resource firewallRules 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = [for rule in ipAddressRules: {
  parent: sqlServer
  name: contains(rule, 'name') ? rule.name : 'ClientIPRule-${uniqueString(rule.startIpAddress)}'
  properties: {
    startIpAddress: rule.startIpAddress
    endIpAddress: contains(rule, 'endIpAddress') ? rule.endIpAddress : rule.startIpAddress
  }
}]

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseEdition
    tier: databaseTier
    capacity: databaseCapacity
  }
  kind: 'v12.0,user'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: zoneRedundant
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

// Database advanced threat protection
resource databaseAdvancedThreatProtection 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: sqlDatabase
  name: 'Default'
  properties: {
    state: enableAdvancedThreatProtection ? 'Enabled' : 'Disabled'
  }
}

// Database auditing settings
resource databaseAuditingSettings 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    state: enableAuditing ? 'Enabled' : 'Disabled'
    retentionDays: enableAuditing ? 30 : 0
    isAzureMonitorTargetEnabled: enableAuditing
    storageAccountSubscriptionId: enableAuditing ? subscription().subscriptionId : '00000000-0000-0000-0000-000000000000'
  }
}

// Backup retention policies
resource backupShortTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2024-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
}

// Transparent data encryption
resource transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  parent: sqlDatabase
  name: 'Current'
  properties: {
    state: enableTransparentDataEncryption ? 'Enabled' : 'Disabled'
  }
}

// Database advisor configurations
resource createIndexAdvisor 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: sqlDatabase
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource forceLastGoodPlanAdvisor 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: sqlDatabase
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

// Outputs
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = sqlDatabase.name
output sqlServerName string = sqlServer.name
output connectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};User Id=${administratorLogin};Password=${administratorLoginPassword};'
