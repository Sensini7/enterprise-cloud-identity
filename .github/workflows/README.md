# GitHub Actions for Enterprise Cloud Identity

## Basic Structure

### PowerShell

**Workflow Dispatch**: Each workflow has two standard fields which are configured as workflow dispatches, the values of which are specified at runtime. These are:
- Environment: Specifies the Entra ID tenant that the workflow will be run against.
- Execute: Specifies whether the workflow will be run in deployment or drift detection mode. This should always default to **drift detection** mode.

All other inputs should be specified through repository variables to facilitate execution of workflows through a CI/CD pipeline. <br>

**Environment Variables**: Environment variables are used for 2 functions:
- Connection variables: Values which define the connections to Entra ID, such as public vs. government tenant and whether to use OIDC for connections to Entra ID.
- Optional variables: Values which are optional in functions called by the workflow. Passing through an environment variable allows for clean handling of blank repository variable values. 

**Module Checkout**: Each workflow performs a sparce checkout of 2 modules. These are:
- Feature module: The module which hosts the code specific to the feature being implemented.
- Common module: The module which hosts code which is shared across all other modules to reduce duplication of code.

**Deployment Enviroment**: The deployment environment (Azure Commercial vs. US Government) has multiple associated parameters based upon which tool is being used to connect (such as Graph PowerShell, Azure PowerShell or Azure CLI). Although each of these tools expresses its deployment environment with a different parameter value, they all express whether the pipeline is connecting to a Commercial or Government tenant. <br>

The appropriate parameters for each of these is calculated based on the value of the repository variable **IS_AZURE_GOV**.

**Service Principal Connections**: All workflows connect using an Entra ID service principal, using a client ID and client secret. The client secret is stored as a secret in the git repository. An access token is retrieved using the service principal and subsequently used to connect to Entra ID and Azure. <br>

Service Principals are configured as multi-tenant apps and are homed in a single tenant within each sovereign cloud boundary (e.g. Azure Public vs. Azure Government). In tenants other than those in which they are homed, service principals are added as Enterprise Apps and granted tenant-level permissions by granting admin consent to the associated applications.

**Prerequisite Modules**: All modules imported from the module repository are checked out using a sparse checkout in the **Module Checkout** step. They are subsequently imported by referencing the module psd1 file.

### Terraform

Architecture, dataflows, and workflows based on below link :

https://github.com/Azure-Samples/terraform-github-actions 


## PowerShell Workflows

### ps-set-cross-tenant-access-setting-defaults-b2b

**Associated Module:** EZD.ECI.CrossTenantAccess <br><br>
**Associated Function:** Set-CrossTenantAccessSettingDefaults <br><br>
**Description:** Configures the Entra B2B cross-tenant access settings which apply when another tenant does not have an explicitly defined Entra B2B organizational relationship with the tenant. <br><br>

---

### ps-set-auth-methods

**Associated Module:** EZD.ECI.AuthMethodPolicies <br><br>
**Associated Functions:**
- Update-EntraCertificateAuthorities
- Update-EmailAuthMethod
- Update-Fido2AuthMethod
- Update-MicrosoftAuthenticatorAuthmethod
- Update-SmsAuthMethod
- Update-SoftwareOathAuthMethod
- Update-TemporaryAccessPassAuthMethod
- Update-VoiceAuthMethod
- Update-X509AuthMethod
- Update-AuthMethodMigrationState

**Description:** Configures Entra ID authentication methods and associated prerequisites, such as certificate authorities. After configuration of authentication methods, it sets the Entra ID authentication method migration state so that legacy authentication method settings are no longer used.

### Unique Features

**Optional Input Parameters** <br><br>
Not all parameters which can be accepted by the functions called by the workflow are required. For example, the authentication method functions are designed to automatically set Include Targets to all_users if no specific target is specified. This is intentional, to reduce the operational overhead associated with maintaining the variables used by the CI/CD pipeline.

To facilitate this behavior, the allowed variables are captured in authentication method variable lists and passed through a function called **New-ParameterList**, which identifies whether the variables are null and excludes any null variables from a subsequent parameter list hash table.

This hash table is subsequently passed to the functions called by the workflow using a splat variable.

**Complex Objects** <br><br>
The functions called by the workflow are dependent upon complex objects such as collections and hash tables. It is important that these values be passed as complex objects because the underlying PowerShell cmdlets which use them are Microsoft Graph calls which accept a formatted body parameter object as an input.

For cross-compatibility, these are passed to the workflow as JSON objects and converted from JSON to PowerShell arrays using the cmdlet ConvertFrom-Json.

**Dependent Workflows** <br><br>
This workflow calls numerous functions, some of which depend upon the successful completion of prior functions to successfully execute. Each function in the workflow returns exit logs and an exit code. If the exit code indicates a failure (any value other than "2"), then the workflow halts execution and returns the logs for the function which failed execution.

**Consolidated Exit Logs** <br><br>
Each function in the workflow returns exit logs and an exit code. Following execution of each function, an **$ExitLogs** variable is appended with the exit logs of the function. If any drift is detected upon execution of any of the functions, then the consolidated exit logs are returned at the end of the workflow.

---

### ps-set-activity-based-timeout-policy-azure-portal

**Associated Module:** EZD.ECI.ActivityBasedTimeout <br><br>
**Associated Function:** Set-ActivityBasedTimeoutPolicy <br><br>
**Description:** Configures the inactivity timeout for Microsoft first-party applications such as the Azure Portal.

---

### ps-set-cross-tenant-access

**TBD - In Development**

---

### ps-set-enterprise-app-user-consent-setting

**Associated Module:** EZD.ECI.PolicyAuthorizationPolicy <br><br>
**Associated Function:** Set-EnterpriseAppUserConsentSetting <br><br>
**Description:** Configures the Enterprise App User Consent settings, which determine whether users are permitted to consent to all applications, a subset of applications or no applications.

---

### ps-set-default-user-role

**Associated Module:** EZD.ECI.PolicyAuthorizationPolicy <br><br>
**Associated Function:** Set-DefaultUserRole <br><br>
**Description:** Configures the Default User Role settings, which determine the default permissions held by standard users, such as ability to create app registrations, B2C tenants and security groups.

---

### ps-set-group-creators-group

**Associated Module:** EZD.ECI.DirectorySetting <br><br>
**Associated Function:** Set-GroupCreatorsGroup <br><br>
**Description:** Configures a Microsoft 365 Group Creators Group, which restricts the users who are permitted to create Microsoft 365 Groups to only the members of a specified security group.

---

### ps-set-password-expiration-policy

**Associated Module:** EZD.ECI.PasswordPolicy <br><br>
**Associated Function:** Set-PasswordExpiration <br><br>
**Description:** Configures the password expiration policy (in days) for an Entra ID tenant. This can be set to a specified number of days, or can be set to never expire.

---

### ps-set-smart-lockout

**Associated Module:** EZD.ECI.DirectorySetting <br><br>
**Associated Function:** Update-PasswordProtection <br><br>
**Description:** Configures the Password Protection directory object and associated settings for a specified Entra ID tenant. This includes smart lockout settings, banned password list and associated settings.

---

### ps-create-emergency-accounts
**Associated Module:** EZD.ECI.EmergencyAccounts <br><br>
**Associated Function:** New-EmergencyAccounts <br><br>
**Description:** Creates 2 cloud-only Entra ID emergency access accounts, sets a random password for each and adds them to the Emergency Access Group for the Entra ID tenant. As this workflow is intended to be run only once when initially onboarding the tenant into the solution, **it does not support drift detection.**

---

### ps-set-sign-in-text

**Associated Module:** EZD.ECI.SignInText <br><br>
**Associated Function:** Set-SignInText <br><br>
**Description:** Configures the terms of use message which appears in the footer of the sign-in page when accessing the Entra ID tenant. 

---

### ps-set-external-collab-settings

**Associated Module:** EZD.ECI.GuestDefaults <br><br>
**Associated Function:** Set-GuestDefaults <br><br>
**Description:** Configures the external collaboration settings which control default Entra B2B behavior, such as default guest user permissions and restrictions on who can invite B2B guest users.

## Terraform Workflows

### tf-drift

**Description**:

Job that can be run manually or scheduled to run nightly. Performs drift detection and posts a summary of the execution. When solution is deployed this will likely need to be adjusted to align with the DevOps platform it is deployed onto (GitHub, GitLab, etc.)

---

### tf-plan-apply
Used to execute a Terraform Apply command against the specified environment. Comprised of 2 primary steps:
 - Terraform Plan: Runs a terraform plan and saves the artifacts for reference in a subsequent apply step.
 - Terraform Apply: Runs a terraform apply. If Entra ID security defaults are not already disabled in the tenant, disables them so that conditional access policies can be deployed by Terraform.

This workflow is called by either the **tf-plan-apply-management tenant** or **tf-plan-apply-resource-tenant** workflow. This allows for targeted deployments of resources and configurations depending upon the role the tenant plays in the federation architecture. This workflow defines the deployment actions taken in a Terraform deployment, whereas the workflows which call it define which resources should be deployed by those actions by specifying different folders which host the underlying tf files for the deployment.

This workflow supports a `maintenance_mode` input that will allow resources that are protected from deletion by Azure Policy to be deleted. This is necessary when a protected resource must be disposed of, or updated in such a way that requires recreation. Once set to true during a `workflow_dispatch` event, the `maintenance_mode` variable will enable two additional workflow steps named "Enable/Disable Maintenance Mode". The "Enable Maintenance Mode" step performs a targeted Terraform Apply, specifying the Azure Policy definitions resources as the only resources to target. Then, the full Terraform Apply is performed in the next step. During the "Disable Maintenance Mode" step, the value for `maintenance_mode` is hardcoded to `false`. This updates the policy definitions following the change to add all other managed Azure resources back into the policy, ensuring that maintenance mode is disabled and that the system does not remain in a less secure/protected state.

---

### tf-plan-apply-management-tenant
Specifies the location of the tf files which define the resources and settings to be configured in an Entra ID Management tenant and calls the **tf-plan-apply** workflow to instantiate those resources and settings. By specifying a different directory for tf files, a different set of Terraform resources can be deployed. TF files called by this workflow are located in the root of the implementation repository directory.

---

### tf-plan-apply-resource-tenant
Specifies the location of the tf files which define the resources and settings to be configured in an Entra ID Resource tenant and calls the **tf-plan-apply** workflow to instantiate those resources and settings. By specifying a different directory for tf files, a different set of Terraform resources can be deployed. TF files called by this workflow are located in the root of the implementation repository directory.

---

### tf-import
Used to import the state of existing Azure or Entra ID resources into the Terraform state. This allows existing resources to be brought under management rather than deploying new resources. This is intended to be used when bringing an existing Entra ID tenant under administration, rather than deploying security baselines to a new tenant. <br>

Required parameters:
- Resource address: Terraform semantic resource address
- Cloud resource identifier: The identifier, often resource ID, that Terraform is expecting per the Terraform resource-specific documentation

---

### tf-state-rm
Removes a resource from Terraform state. This allows resources to be removed from state in Terraform while retaining the resource in the managed environment. Must be targeted toward 1 resource at a time (cannot remove multiple resources at a time). <br>

Required parameters:
- Resource address: Terraform semantic resource address

---

### tf-test
Performs continuous integration tests. This is limited to static checks, and does not make changes to the environment. This includes:
- Terraform init (without backend): Confirms we can initialize if there is a backend
- Terraform validate / fmt: Ensures code quality standards have been met
- Checkov Infrastructure Security Testing
  - Looks at Terraform
  - Looks at GitHub Actions (YAML)