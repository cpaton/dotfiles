@{
    # https://learn.microsoft.com/en-gb/powershell/utility-modules/psscriptanalyzer/rules/readme?view=ps-modules
    IncludeDefaultRules = $true
    Rules               = @{
        PSAlignAssignmentStatement                 = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSPlaceOpenBrace                           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $false
        }
        PSPlaceCloseBrace                          = @{
            Enable             = $true
            NoEmptyLineBefore  = $true
            IgnoreOneLineBlock = $false
            NewLineAfter       = $true
        }
        PSUseConsistentIndentation                 = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseConsistentWhitespace                  = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
        PSAvoidExclaimOperator                     = @{
            Enable = $true
        }
        PSAvoidLongLines                           = @{
            Enable            = $true
            MaximumLineLength = 220
        }
        PSAvoidSemicolonsAsLineTerminators         = @{
            Enable = $true
        }
        PSAvoidUsingCmdletAliases                  = @{
            'allowlist' = @()
        }
        PSAvoidUsingDoubleQuotesForConstantStrings = @{
            Enable = $true
        }
        PSProvideCommentHelp                       = @{
            Enable                  = $true
            ExportedOnly            = $false
            BlockComment            = $true
            VSCodeSnippetCorrection = $false
            Placement               = 'before'
        }
        PSUseCorrectCasing                         = @{
            Enable        = $true
            CheckCommands = $true
            CheckKeyword  = $true
            CheckOperator = $true
        }
        PSUseSingularNouns                         = @{
            Enable        = $true
            NounAllowList = @()
        }
    }
}
