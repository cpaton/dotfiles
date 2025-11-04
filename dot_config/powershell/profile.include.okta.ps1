function okta-api-login()
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]
        $Scopes = @(
            'okta.users.read'
            'okta.groups.read'
            'okta.apps.read'
        )
    )

    $awsProfile = "tooling"
    awssso -AwsAccount aws-tpicap-tooling -ProfileName $awsProfile
    $jsonWebKeySecretValue = Get-SECSecretValue -SecretId 'pace/okta/automation' -ProfileName $awsProfile -Region 'eu-west-1'
    $jsonWebKeySecure = ConvertTo-SecureString -String $jsonWebKeySecretValue.SecretString -AsPlainText -Force
    Get-OktaOAuthAccessToken -JsonWebKey $jsonWebKeySecure -ClientId '0oa5ealhc8qhJsj3i0i7' -Scopes $Scopes | Set-OktaOAuthAccessToken
}